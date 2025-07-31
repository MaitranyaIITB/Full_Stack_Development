const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const path = require('path');
const bcrypt = require('bcrypt'); 
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = 3000;

// Set up DB pool
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// Middleware
app.use(bodyParser.urlencoded({ extended: false }));
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false
}));

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

function isAuthenticated(req, res, next) {
  if (!req.session.userId) {
    return res.redirect('/login');
  }
  next();
}

app.get('/signup', (req, res) => {
  if (req.session.userId) {
    return res.redirect('/dashboard');
  }
  res.render('signup');
});

app.post('/signup', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // Hash the password using bcrypt
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user into the database
    const result = await pool.query(
      'INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3) RETURNING user_id',
      [username, email, hashedPassword]
    );

    // Store user ID in session
    req.session.userId = result.rows[0].user_id;

    // Redirect to dashboard
    res.redirect('/dashboard');
  } catch (err) {
    console.error('Signup error:', err);
    res.status(500).send('Something went wrong during signup.');
  }
});

app.get('/login', (req, res) => {
  // Prevent logged-in users from accessing login again
  if (req.session.userId) {
    return res.redirect('/dashboard');
  }
  res.render('login');
});

app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // 1. Fetch user from database using email
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

    if (result.rows.length === 0) {
      // No such email
      return res.status(401).send('Invalid email');
    }

    const user = result.rows[0];

    // 2. Compare hashed password
    const match = await bcrypt.compare(password, user.password_hash);

    if (!match) {
      return res.status(401).send('Invalid password');
    }

    // 3. Login successful
    req.session.userId = user.user_id;
    res.redirect('/dashboard');
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).send('Something went wrong during login.');
  }
});

app.get('/dashboard', isAuthenticated, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT username FROM users WHERE user_id = $1',
      [req.session.userId]
    );
    const username = result.rows[0].username;
    res.render('dashboard', { username });
  } catch (err) {
    console.error('Dashboard error:', err);
    res.status(500).send('Something went wrong.');
  }
});

app.get('/list-products', isAuthenticated, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY product_id');
    res.render('list-products', { products: result.rows });
  } catch (err) {
    console.error('List Products error:', err);
    res.status(500).send('Unable to load products.');
  }
});

app.get('/add-to-cart', isAuthenticated, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY name');
    res.render('add-to-cart', { products: result.rows });
  } catch (err) {
    console.error('Add to Cart (GET) error:', err);
    res.status(500).send('Failed to load product list.');
  }
});

app.post('/add-to-cart', isAuthenticated, async (req, res) => {
  const { product_id, quantity } = req.body;
  const user_id = req.session.userId;

  try {
    // Check if product already in cart
    const check = await pool.query(
      'SELECT * FROM cart WHERE user_id = $1 AND item_id = $2',
      [user_id, product_id]
    );

    if (check.rows.length > 0) {
      // Update existing quantity
      await pool.query(
        'UPDATE cart SET quantity = quantity + $1 WHERE user_id = $2 AND item_id = $3',
        [quantity, user_id, product_id]
      );
    } else {
      // Insert new row
      await pool.query(
        'INSERT INTO cart (user_id, item_id, quantity) VALUES ($1, $2, $3)',
        [user_id, product_id, quantity]
      );
    }

    res.redirect('/dashboard');
  } catch (err) {
    console.error('Add to Cart (POST) error:', err);
    res.status(500).send('Could not add to cart.');
  }
});

app.get('/remove-from-cart', isAuthenticated, async (req, res) => {
  const user_id = req.session.userId;

  try {
    const result = await pool.query(`
      SELECT c.item_id, c.quantity, p.name
      FROM cart c
      JOIN products p ON c.item_id = p.product_id
      WHERE c.user_id = $1
    `, [user_id]);

    res.render('remove-from-cart', { cartItems: result.rows });
  } catch (err) {
    console.error('Remove from Cart (GET) error:', err);
    res.status(500).send('Could not load your cart.');
  }
});

app.post('/remove-from-cart', isAuthenticated, async (req, res) => {
  const { item_id } = req.body;
  const user_id = req.session.userId;

  try {
    await pool.query(
      'DELETE FROM cart WHERE user_id = $1 AND item_id = $2',
      [user_id, item_id]
    );

    res.redirect('/dashboard');
  } catch (err) {
    console.error('Remove from Cart (POST) error:', err);
    res.status(500).send('Failed to remove item.');
  }
});

app.get('/display-cart', isAuthenticated, async (req, res) => {
  const user_id = req.session.userId;

  try {
    const result = await pool.query(`
      SELECT p.name, p.price, c.quantity
      FROM cart c
      JOIN products p ON c.item_id = p.product_id
      WHERE c.user_id = $1
    `, [user_id]);

    res.render('display-cart', { cartItems: result.rows });
  } catch (err) {
    console.error('Display Cart error:', err);
    res.status(500).send('Unable to load cart.');
  }
});

app.post('/place-order', isAuthenticated, async (req, res) => {
  const user_id = req.session.userId;
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const cartResult = await client.query(`
      SELECT c.item_id, c.quantity, p.price,p.stock_quantity, p.name
      FROM cart c
      JOIN products p ON c.item_id = p.product_id
      WHERE c.user_id = $1
    `, [user_id]);

    const cartItems = cartResult.rows;

    if (cartItems.length === 0) {
      await client.query('ROLLBACK');
      return res.send(' Your cart is empty.');
    }

    for (const item of cartItems) {
      if (item.quantity > item.stock_quantity) {
      return res.status(400).send(`Not enough stock for  ${item.name}`);
      }
    }

    const totalAmount = cartItems.reduce((total, item) => {
      return total + item.price * item.quantity;
    }, 0);

    const orderInsert = await client.query(`
      INSERT INTO orders (user_id, total_amount)
      VALUES ($1, $2)
      RETURNING order_id, order_date
    `, [user_id, totalAmount]);

    
    const orderId = orderInsert.rows[0].order_id;
    const orderDate = orderInsert.rows[0].order_date;

     for (const item of cartItems) {
      await client.query(`
        INSERT INTO orderitems (order_id, product_id, quantity, price)
        VALUES ($1, $2, $3, $4)
      `, [orderId, item.item_id, item.quantity, item.price]);

      await client.query(
        `UPDATE products SET stock_quantity = stock_quantity - $1
         WHERE product_id = $2`,
        [item.quantity, item.item_id]
      );
    }

    await client.query('DELETE FROM cart WHERE user_id = $1', [user_id]);

    await client.query('COMMIT');
    req.session.lastOrderId = orderId;
    res.redirect('/order-confirmation');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Place Order error:', err);
    res.status(500).send('Could not place order.');
  } finally {
    client.release();
  }
});

app.get('/order-confirmation', isAuthenticated, async (req, res) => {
  const user_id = req.session.userId;
  const order_id = req.session.lastOrderId;

  if (!order_id) {
    return res.redirect('/dashboard');
  }
  try {
    // 1. Fetch order details for the user
    const orderResult = await pool.query(
      `SELECT order_id, order_date, total_amount
       FROM orders
       WHERE order_id = $1 AND user_id = $2`,
      [order_id, user_id]
    );

    if (orderResult.rows.length === 0) {
      return res.status(404).send('Order not found or access denied.');
    }

    const order = orderResult.rows[0];

     const itemsResult = await pool.query(`
      SELECT oi.product_id, oi.quantity, oi.price, p.name
      FROM orderitems oi
      JOIN products p ON oi.product_id = p.product_id
      WHERE oi.order_id = $1
      ORDER BY oi.product_id
    `, [order_id]);

    const items = itemsResult.rows.map(item => ({
      ...item,
      price: parseFloat(item.price)
    }));

    const totalAmount = parseFloat(order.total_amount);

    res.render('order-confirmation', {
      order,
      items,
      totalAmount
    });
    } catch (err) {
    console.error('Order Confirmation error:', err);
    res.status(500).send('Failed to load order confirmation.');
  }
});

app.get('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.send('Error logging out');
    }
    res.redirect('/login');
  });
});


// Test route
app.get('/', (req, res) => {
  res.send('Server is running!');
});


app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
 

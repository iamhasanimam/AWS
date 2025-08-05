# UserService Architecture and Request Flow

## 1. Big Picture
Your **UserService** is a backend API that:

- **Listens for HTTP requests** from:
  - The frontend (login/signup/profile)
  - Other backend services (e.g., OrderService verifying users)
- **Processes the request**:
  - Validates inputs
  - Connects to PostgreSQL
  - Hashes passwords / verifies JWT tokens
- **Responds with JSON**

---

## 2. How the Code is Layered

We split it into layers so it’s clear and easy to maintain:

| Layer | Files | Role |
|-------|-------|------|
| Entry Point | `server.js` | Starts the app, loads env variables |
| App Config | `src/app.js` | Sets up Express, routes, middlewares |
| Routing | `src/routes/userRoutes.js` | Maps URL paths to controller functions |
| Controller | `src/controllers/userController.js` | Actual logic for signup/login |
| Database | `src/config/db.js` | PostgreSQL connection pool |
| Auth Middleware | `src/middleware/auth.js` | Checks JWT token validity |

---

## 3. Request Flow Example — Signup

### Example Request
```bash
POST /users/signup
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "pass123"
}
```

### Step-by-step
1. **User hits the endpoint**
   - The HTTP request arrives at the Express server (`server.js`).
2. **Route matches**
   - Express passes it to `/users` route handler in `src/app.js`.
   - In `src/routes/userRoutes.js`:
     ```js
     router.post('/signup', signup);
     ```
3. **Controller logic runs (signup function)**
   - Reads email and password from `req.body`.
   - Hashes password using `bcrypt`.
   - Runs SQL query via `pool.query()` to insert into PostgreSQL.
   - Sends back a JSON success message:
     ```json
     { "message": "User created successfully" }
     ```
4. **Database interaction**
   - Uses `src/config/db.js` to create a connection pool to PostgreSQL RDS.
   - The pool handles connections efficiently for multiple requests.

---

## 4. Request Flow Example — Login

### Example Request
```bash
POST /users/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "pass123"
}
```

### Step-by-step
1. Request arrives at `/users/login`.
2. Route in `userRoutes.js` sends it to `login()` in `userController.js`.
3. **Controller:**
   - Looks up user in PostgreSQL.
   - Compares hashed password with `bcrypt.compare()`.
   - If valid → creates JWT token:
     ```js
     const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET);
     ```
   - Responds with:
     ```json
     { "token": "eyJhbGciOiJIUzI1NiIsIn..." }
     ```

---

## 5. Using JWT for Authentication

When the frontend (or another service like OrderService) calls a protected API:

```http
GET /users/profile
Authorization: Bearer <token>
```

**`auth.js` middleware checks:**
1. Is there a token in the Authorization header?
2. Is it valid (using `jwt.verify()`)?
3. If valid → request continues to controller.
4. If invalid → returns `401 Unauthorized`.

---

## 6. Interaction with Other Services

- **Frontend → UserService**  
  Directly calls `/signup` and `/login`.

- **OrderService → UserService**  
  Verifies user identity before placing an order using the JWT token.

- **ProductService**  
  Usually doesn’t talk to UserService directly unless you add user-specific product features.

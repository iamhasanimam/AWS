
# ProductService Architecture and Request Flow

## 1. Big Picture
Your **ProductService** is a backend API that:

- **Listens for HTTP requests** from:
  - The frontend (browse products, search, view product details)
  - Other backend services (e.g., OrderService fetching product info before creating an order)

- **Processes the request**:
  - Validates inputs
  - Connects to MongoDB Atlas
  - Retrieves or stores product data
  - Responds with JSON

---

## 2. How the Code is Layered
We split it into layers so it’s clear and easy to maintain:

| Layer           | Files                                | Role |
|-----------------|--------------------------------------|------|
| Entry Point     | `main.py`                            | Starts FastAPI app |
| App Config      | `app/main.py`                        | Sets up routes, dependencies |
| Routing         | `app/routes/product_routes.py`       | Maps URL paths to controller functions |
| Controller      | `app/controllers/product_controller.py` | Actual logic for handling products |
| Database        | `app/config/db.py`                   | MongoDB client setup |
| Models (Optional) | `app/models/product_model.py`      | Product data structure (Pydantic) |

---

## 3. Request Flow Example — Add Product

### Example Request
```bash
POST /products
Content-Type: application/json

{
  "name": "Laptop",
  "price": 1200,
  "description": "High performance laptop"
}
```

### Step-by-step
1. **Request hits the endpoint**  
   FastAPI receives request in `main.py`.

2. **Route matches**  
   `/products` POST → handled by `product_routes.py`:
   ```python
   router.post("/products")(add_product)
   ```

3. **Controller logic runs (`add_product` function)**  
   - Validates request body with Pydantic model.
   - Inserts the product into MongoDB:
     ```python
     db.products.insert_one(product.dict())
     ```

4. **Database interaction**  
   - Uses `app/config/db.py` MongoDB client connection to MongoDB Atlas.
   - MongoDB stores the new product document.

---

## 4. Request Flow Example — Get Products

### Example Request
```bash
GET /products
```

### Step-by-step
1. **Request arrives** at `/products` endpoint.

2. **Route matches** in `product_routes.py`:
   ```python
   router.get("/products")(get_products)
   ```

3. **Controller**:
   - Queries MongoDB for all products:
     ```python
     products = list(db.products.find({}, {"_id": 0}))
     ```

4. **Returns the result as JSON**:
   ```json
   [
     { "name": "Laptop", "price": 1200, "description": "High performance laptop" }
   ]
   ```

---

## 5. Authentication (Optional for Learning)
If you want to protect product APIs (e.g., adding products only for admin users):

```http
POST /products
Authorization: Bearer <token>
```

Token verification can be done by:
- Validating JWT inside ProductService itself.
- Calling **UserService** `/verify` endpoint to confirm token is valid.

---

## 6. Interaction with Other Services

### **Frontend → ProductService**
- Requests product list, details, search results.

### **OrderService → ProductService**
- Calls product API to get product info (name, price) when creating an order.

### **UserService → ProductService**
- Usually no direct calls unless you implement user-specific product features (favorites, recommendations).

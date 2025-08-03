package com.example.karate.controller;

import com.example.karate.model.Product;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private List<Product> products = new ArrayList<>();
    private Long nextId = 1L;

    public ProductController() {
        // Initialize with some dummy data
        products.add(new Product(nextId++, "Laptop", "High-performance laptop", new BigDecimal("999.99"), "Electronics", 10));
        products.add(new Product(nextId++, "Smartphone", "Latest smartphone model", new BigDecimal("699.99"), "Electronics", 25));
        products.add(new Product(nextId++, "Coffee Mug", "Ceramic coffee mug", new BigDecimal("12.99"), "Home", 100));
    }

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        List<Product> filteredProducts = products.stream()
                .filter(product -> category == null || product.getCategory().equals(category))
                .filter(product -> minPrice == null || product.getPrice().compareTo(minPrice) >= 0)
                .filter(product -> maxPrice == null || product.getPrice().compareTo(maxPrice) <= 0)
                .skip((long) page * size)
                .limit(size)
                .toList();

        return ResponseEntity.ok(filteredProducts);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        Optional<Product> product = products.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst();

        return product.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        product.setId(nextId++);
        products.add(product);
        return ResponseEntity.status(HttpStatus.CREATED).body(product);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Long id, @RequestBody Product updatedProduct) {
        Optional<Product> existingProduct = products.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst();

        if (existingProduct.isPresent()) {
            Product product = existingProduct.get();
            product.setName(updatedProduct.getName());
            product.setDescription(updatedProduct.getDescription());
            product.setPrice(updatedProduct.getPrice());
            product.setCategory(updatedProduct.getCategory());
            product.setQuantity(updatedProduct.getQuantity());
            return ResponseEntity.ok(product);
        }
        return ResponseEntity.notFound().build();
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Product> partialUpdateProduct(@PathVariable Long id, @RequestBody Product updates) {
        Optional<Product> existingProduct = products.stream()
                .filter(p -> p.getId().equals(id))
                .findFirst();

        if (existingProduct.isPresent()) {
            Product product = existingProduct.get();
            if (updates.getName() != null) product.setName(updates.getName());
            if (updates.getDescription() != null) product.setDescription(updates.getDescription());
            if (updates.getPrice() != null) product.setPrice(updates.getPrice());
            if (updates.getCategory() != null) product.setCategory(updates.getCategory());
            return ResponseEntity.ok(product);
        }
        return ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        boolean removed = products.removeIf(product -> product.getId().equals(id));
        return removed ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    @GetMapping("/categories")
    public ResponseEntity<List<String>> getCategories() {
        List<String> categories = products.stream()
                .map(Product::getCategory)
                .distinct()
                .toList();
        return ResponseEntity.ok(categories);
    }
}
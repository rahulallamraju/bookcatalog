package com.example.bookcatalog;

import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/books")
public class BookController {
    private final List<Book> books = new ArrayList<>();

    public BookController() {
        books.add(new Book("Clean Code", "Robert C. Martin"));
    }

    @GetMapping
    public List<Book> getBooks() {
        return books;
    }

    @PostMapping
    public Book addBook(@RequestBody Book book) {
        books.add(book);
        return book;
    }
}

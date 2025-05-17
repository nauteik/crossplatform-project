package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Tag;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.TagService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tags")
@CrossOrigin(origins = "*")
public class TagController {

    private final TagService tagService;

    @Autowired
    public TagController(TagService tagService) {
        this.tagService = tagService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Tag>>> getAllTags() {
        List<Tag> tags = tagService.getAllTags();
        ApiResponse<List<Tag>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                tags
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<Tag>>> getActiveTags() {
        List<Tag> tags = tagService.getTagsByActive(true);
        ApiResponse<List<Tag>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                tags
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Tag>> getTagById(@PathVariable String id) {
        return tagService.getTagById(id)
                .map(tag -> {
                    ApiResponse<Tag> response = new ApiResponse<>(
                            ApiStatus.SUCCESS.getCode(),
                            ApiStatus.SUCCESS.getMessage(),
                            tag
                    );
                    return ResponseEntity.ok(response);
                })
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ApiResponse<>(
                                ApiStatus.NOT_FOUND.getCode(),
                                ApiStatus.NOT_FOUND.getMessage()
                        )));
    }

    @GetMapping("/name/{name}")
    public ResponseEntity<ApiResponse<Tag>> getTagByName(@PathVariable String name) {
        Tag tag = tagService.getTagByName(name);
        if (tag != null) {
            ApiResponse<Tag> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    tag
            );
            return ResponseEntity.ok(response);
        } else {
            ApiResponse<Tag> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    ApiStatus.NOT_FOUND.getMessage()
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Tag>> createTag(@RequestBody Tag tagRequest) {
        Tag createdTag = tagService.createTag(tagRequest);
        ApiResponse<Tag> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                createdTag
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Tag>> updateTag(@PathVariable String id, @RequestBody Tag tagDetails) {
        try {
            Tag updatedTag = tagService.updateTag(id, tagDetails);
            ApiResponse<Tag> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    updatedTag
            );
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            ApiResponse<Tag> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    ApiStatus.NOT_FOUND.getMessage()
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteTag(@PathVariable String id) {
        try {
            tagService.deleteTag(id);
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage()
            );
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    ApiStatus.NOT_FOUND.getMessage()
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }
} 
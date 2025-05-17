package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Tag;
import com.example.ecommerceproject.repository.TagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class TagService {

    private final TagRepository tagRepository;

    @Autowired
    public TagService(TagRepository tagRepository) {
        this.tagRepository = tagRepository;
    }

    public List<Tag> getAllTags() {
        return tagRepository.findAll();
    }

    public List<Tag> getTagsByActive(boolean active) {
        return tagRepository.findAll().stream()
                .filter(tag -> tag.isActive() == active)
                .collect(Collectors.toList());
    }

    public Optional<Tag> getTagById(String id) {
        return tagRepository.findById(id);
    }

    public Tag getTagByName(String name) {
        return tagRepository.findByName(name);
    }

    public Tag createTag(Tag tagRequest) {
        Tag tag = new Tag();
        tag.setName(tagRequest.getName());
        tag.setColor(tagRequest.getColor());
        tag.setDescription(tagRequest.getDescription());
        tag.setActive(tagRequest.isActive());
        tag.setCreatedAt(LocalDateTime.now());
        return tagRepository.save(tag);
    }

    public Tag updateTag(String id, Tag tagDetails) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tag not found with id: " + id));
        
        tag.setName(tagDetails.getName());
        tag.setColor(tagDetails.getColor());
        tag.setDescription(tagDetails.getDescription());
        tag.setActive(tagDetails.isActive());
        
        return tagRepository.save(tag);
    }

    public void deleteTag(String id) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tag not found with id: " + id));
        tagRepository.delete(tag);
    }
} 
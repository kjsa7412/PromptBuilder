package com.promptbuilder.service;

import com.promptbuilder.common.ApiException;
import com.promptbuilder.mapper.BookmarkMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class BookmarkService {

    @Autowired
    private BookmarkMapper bookmarkMapper;

    public List<Map<String, Object>> getMyBookmarks(String userId) {
        return bookmarkMapper.findByUserId(userId);
    }

    public void addBookmark(String userId, String promptId) {
        int exists = bookmarkMapper.countByUserAndPrompt(userId, promptId);
        if (exists > 0) {
            throw ApiException.badRequest("PROMPT_004", "이미 북마크된 프롬프트입니다");
        }
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("promptId", promptId);
        bookmarkMapper.insert(params);
    }

    public void removeBookmark(String userId, String promptId) {
        bookmarkMapper.delete(userId, promptId);
    }
}

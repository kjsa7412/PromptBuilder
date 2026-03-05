package com.promptbuilder.common;

import java.util.HashMap;
import java.util.Map;

public class ApiResponse {

    public static Map<String, Object> ok(Object data) {
        Map<String, Object> res = new HashMap<>();
        res.put("data", data);
        return res;
    }

    public static Map<String, Object> ok(Object data, Map<String, Object> meta) {
        Map<String, Object> res = new HashMap<>();
        res.put("data", data);
        res.put("meta", meta);
        return res;
    }

    public static Map<String, Object> error(String code, String message) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", code);
        res.put("message", message);
        res.put("details", new HashMap<>());
        return res;
    }

    public static Map<String, Object> error(String code, String message, Object details) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", code);
        res.put("message", message);
        res.put("details", details);
        return res;
    }

    public static Map<String, Object> meta(long total, int page, int size) {
        Map<String, Object> meta = new HashMap<>();
        meta.put("total", total);
        meta.put("page", page);
        meta.put("size", size);
        return meta;
    }
}

package com.promptbuilder.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface PostPromptMapper {
    List<Map<String, Object>> findByPromptId(@Param("promptId") String promptId);
    Map<String, Object> findById(@Param("id") String id);
    void insert(Map<String, Object> params);
    void update(Map<String, Object> params);
    void delete(@Param("id") String id, @Param("promptId") String promptId);
    void insertVariable(Map<String, Object> params);
    void deleteVariablesByPostPromptId(@Param("postPromptId") String postPromptId);
    List<Map<String, Object>> findVariablesByPostPromptId(@Param("postPromptId") String postPromptId);
    long countByPromptId(@Param("promptId") String promptId);
}

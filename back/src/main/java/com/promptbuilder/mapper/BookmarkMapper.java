package com.promptbuilder.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface BookmarkMapper {

    List<Map<String, Object>> findByUserId(@Param("userId") String userId);

    int countByUserAndPrompt(@Param("userId") String userId, @Param("promptId") String promptId);

    void insert(Map<String, Object> params);

    void delete(@Param("userId") String userId, @Param("promptId") String promptId);
}

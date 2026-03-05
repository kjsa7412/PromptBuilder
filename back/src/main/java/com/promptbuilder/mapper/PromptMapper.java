package com.promptbuilder.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface PromptMapper {

    List<Map<String, Object>> findTrending(@Param("limit") int limit);

    List<Map<String, Object>> findRandom(@Param("limit") int limit);

    List<Map<String, Object>> findNew(@Param("limit") int limit);

    List<Map<String, Object>> search(
            @Param("q") String q,
            @Param("tag") String tag,
            @Param("sort") String sort,
            @Param("offset") int offset,
            @Param("size") int size
    );

    long countSearch(@Param("q") String q, @Param("tag") String tag);

    Map<String, Object> findById(@Param("id") String id);

    List<Map<String, Object>> findVariablesByVersionId(@Param("versionId") String versionId);

    void insertPrompt(Map<String, Object> params);

    void updatePrompt(Map<String, Object> params);

    void incrementGenerateCount(@Param("id") String id);
}

package com.promptbuilder.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface PromptMapper {

    List<Map<String, Object>> findTrending(@Param("limit") int limit, @Param("offset") int offset);

    List<Map<String, Object>> findRandom(@Param("limit") int limit);

    List<Map<String, Object>> findNew(@Param("limit") int limit, @Param("offset") int offset);

    List<Map<String, Object>> search(
            @Param("q") String q,
            @Param("tag") String tag,
            @Param("author") String author,
            @Param("sort") String sort,
            @Param("offset") int offset,
            @Param("size") int size
    );

    long countSearch(@Param("q") String q, @Param("tag") String tag, @Param("author") String author);

    Map<String, Object> findById(@Param("id") String id);

    List<Map<String, Object>> findVariablesByVersionId(@Param("versionId") String versionId);

    void insertPrompt(Map<String, Object> params);

    void insertVersion(Map<String, Object> params);

    void setCurrentVersion(Map<String, Object> params);

    void insertVariable(Map<String, Object> params);

    void updatePrompt(Map<String, Object> params);

    void incrementGenerateCount(@Param("id") String id);

    void incrementLikeCount(Map<String, Object> params);

    List<Map<String, Object>> findMyPrompts(@Param("userId") String userId);

    long countPublic();

    void updateBodyMarkdown(@Param("promptId") String promptId, @Param("bodyMarkdown") String bodyMarkdown);

    void incrementClipCount(@Param("id") String promptId);

    void decrementClipCount(@Param("id") String promptId);

    Map<String, Object> findByIdForOwner(Map<String, Object> params);

    void updatePromptFull(Map<String, Object> params);

    void softDeletePrompt(Map<String, Object> params);

    void updateVisibility(Map<String, Object> params);

    List<Map<String, Object>> findMyDraftPrompts(@Param("userId") String userId);

    List<Map<String, Object>> findTagsWithCount();
}

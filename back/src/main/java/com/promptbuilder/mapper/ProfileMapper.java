package com.promptbuilder.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Map;

@Mapper
public interface ProfileMapper {

    Map<String, Object> findByUserId(@Param("userId") String userId);

    void upsert(Map<String, Object> params);
}

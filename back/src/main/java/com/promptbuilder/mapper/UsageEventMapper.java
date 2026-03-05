package com.promptbuilder.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Map;

@Mapper
public interface UsageEventMapper {

    void insert(Map<String, Object> params);

    int countGenerateByUserToday(@Param("userId") String userId);
}

package com.steel.steel.models

import kotlinx.serialization.Serializable

/**
 * Plan Day model - Plan day structure
 */
@Serializable
data class PlanDay(
    val id: String,
    val plan: String,
    val week: Int,
    val dayOfWeek: Int,
    val label: String? = null,
    val focus: Map<String, Any>? = null,
    val warmup: Map<String, Any>? = null,
    val cooldown: Map<String, Any>? = null,
    val created: String,
    val updated: String
)
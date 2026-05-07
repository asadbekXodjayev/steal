package com.steel.steel.models

import kotlinx.serialization.Serializable

/**
 * Workout Session model - Session logging
 */
@Serializable
data class WorkoutSession(
    val id: String,
    val user: String,
    val planDay: String? = null,
    val plan: String? = null,
    val startedAt: String? = null,
    val completedAt: String? = null,
    val status: SessionStatus = SessionStatus.IN_PROGRESS,
    val mood: SessionMood? = null,
    val energyLevel: Int? = null,
    val sessionNotes: String? = null,
    val therapyReflection: String? = null,
    val created: String,
    val updated: String
)

@Serializable
enum class SessionStatus {
    in_progress, completed, skipped
}

@Serializable
enum class SessionMood {
    great, good, okay, rough, terrible
}
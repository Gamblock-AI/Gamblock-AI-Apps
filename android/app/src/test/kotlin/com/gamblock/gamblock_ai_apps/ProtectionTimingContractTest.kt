package com.gamblock.gamblock_ai_apps

import org.junit.Assert.assertTrue
import org.junit.Assert.assertEquals
import org.junit.Test

class ProtectionTimingContractTest {
    @Test
    fun patternInterruptDurationMatchesPrototypeAndProposalRange() {
        val duration = ProtectionTimingContract.PATTERN_INTERRUPT_SECONDS
        assertEquals(7, duration)
        assertTrue(duration in 5..10)
    }
}

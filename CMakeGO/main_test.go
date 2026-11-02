package main

import "testing"

func TestSanity(t *testing.T) {
    // Basic sanity test for CI/build pipeline
    if 1+1 != 2 {
        t.Fatal("math is broken")
    }
}
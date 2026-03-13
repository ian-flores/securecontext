test_that("context_builder basic usage", {
  cb <- context_builder(max_tokens = 100L)
  cb <- context_add(cb, "High priority text", priority = 10, label = "high")
  cb <- context_add(cb, "Low priority text", priority = 1, label = "low")
  result <- context_build(cb)

  expect_true(nzchar(result$context))
  expect_true("high" %in% result$included)
  expect_equal(result$total_tokens, sum(count_tokens(c("High priority text", "Low priority text"))))
})

test_that("context_builder respects token limit", {
  cb <- context_builder(max_tokens = 5L)
  cb <- context_add(cb, "This is a much longer text that uses many tokens", priority = 10, label = "long")
  cb <- context_add(cb, "Short", priority = 5, label = "short")
  result <- context_build(cb)

  # "Short" should fit, "long" should not
  expect_true("short" %in% result$included)
  expect_true("long" %in% result$excluded)
})

test_that("context_build() with no items", {
  cb <- context_builder()
  result <- context_build(cb)
  expect_equal(result$context, "")
  expect_equal(result$total_tokens, 0L)
})

test_that("context_reset() clears items", {
  cb <- context_builder()
  cb <- context_add(cb, "text")
  cb <- context_reset(cb)
  result <- context_build(cb)
  expect_equal(result$total_tokens, 0L)
})

test_that("context_builder validates inputs", {
  expect_error(context_add("not_a_builder", "text"), "must be a")
  expect_error(context_build("not_a_builder"), "must be a")
  expect_error(context_reset("not_a_builder"), "must be a")
})

test_that("deprecated cb_add/cb_build/cb_reset still work", {
  cb <- context_builder(max_tokens = 100L)
  lifecycle::expect_deprecated(cb <- cb_add(cb, "text", priority = 1))
  lifecycle::expect_deprecated(result <- cb_build(cb))
  expect_true(nzchar(result$context))
  lifecycle::expect_deprecated(cb <- cb_reset(cb))
  expect_equal(length(cb@items), 0L)
})

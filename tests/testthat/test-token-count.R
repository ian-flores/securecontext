test_that("count_tokens() words method", {
  tokens <- count_tokens("hello world foo bar")
  # 4 words * 1.3 = 5.2, ceiling = 6
  expect_equal(tokens, 6)
})

test_that("count_tokens() chars method", {
  tokens <- count_tokens("abcdefgh", method = "chars")
  # 8 / 4 = 2
  expect_equal(tokens, 2)
})

test_that("count_tokens() vectorized", {
  tokens <- count_tokens(c("hello world", "one two three four"))
  expect_equal(length(tokens), 2L)
  expect_equal(tokens[1], ceiling(2 * 1.3))
  expect_equal(tokens[2], ceiling(4 * 1.3))
})

test_that("estimate_tokens() is alias", {
  expect_equal(
    estimate_tokens("hello world"),
    count_tokens("hello world", method = "words")
  )
})

test_that("count_tokens() validates input", {
  expect_error(count_tokens(123), "must be a character vector")
})

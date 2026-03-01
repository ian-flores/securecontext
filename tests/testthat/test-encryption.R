test_that("new_encryption_key() returns 32-byte raw vector", {
  skip_if_not_installed("openssl")
  key <- new_encryption_key()
  expect_type(key, "raw")
  expect_length(key, 32L)
})

test_that("encrypt/decrypt round-trip with known data", {
  skip_if_not_installed("openssl")
  key <- new_encryption_key()
  data <- charToRaw("hello world, this is a test message")

  encrypted <- encrypt_raw(data, key)
  expect_type(encrypted, "raw")
  expect_false(identical(encrypted, data))

  decrypted <- decrypt_raw(encrypted, key)
  expect_identical(decrypted, data)
})

test_that("wrong key fails to decrypt correctly", {
  skip_if_not_installed("openssl")
  key1 <- new_encryption_key()
  key2 <- new_encryption_key()
  data <- charToRaw("secret data")

  encrypted <- encrypt_raw(data, key1)
  expect_error(decrypt_raw(encrypted, key2))
})

test_that("encrypt_raw rejects invalid key", {
  expect_error(encrypt_raw(charToRaw("x"), raw(16L)), "32-byte raw vector")
  expect_error(encrypt_raw(charToRaw("x"), "not-raw"), "32-byte raw vector")
})

test_that("decrypt_raw rejects invalid key", {
  expect_error(decrypt_raw(raw(32L), raw(16L)), "32-byte raw vector")
})

test_that("resolve_encryption_key() with explicit key", {
  skip_if_not_installed("openssl")
  key <- new_encryption_key()
  result <- resolve_encryption_key(key)
  expect_identical(result, key)
})

test_that("resolve_encryption_key() with NULL and no env var", {
  withr::with_envvar(c(SECURECONTEXT_ENCRYPTION_KEY = NA), {
    result <- resolve_encryption_key(NULL)
    expect_null(result)
  })
})

test_that("resolve_encryption_key() from env var", {
  skip_if_not_installed("openssl")
  key <- new_encryption_key()
  hex <- paste0(as.character(key), collapse = "")
  withr::with_envvar(c(SECURECONTEXT_ENCRYPTION_KEY = hex), {
    result <- resolve_encryption_key(NULL)
    expect_type(result, "raw")
    expect_length(result, 32L)
    expect_identical(result, key)
  })
})

test_that("resolve_encryption_key() rejects invalid explicit key", {
  expect_error(resolve_encryption_key(raw(16L)), "32-byte raw vector")
  expect_error(resolve_encryption_key("not-raw"), "32-byte raw vector")
})

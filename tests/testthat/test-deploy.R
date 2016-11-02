context("deploy")

expect_parse <- function(x, code) {
  expect_equal(unname(x), as.list(parse(text = code)))
  expect_equal(names(x), code)
}

test_that("parse tasks", {
  expect_parse(parse_task_code(" "), character())
  expect_parse(parse_task_code("call1( ); call2()"),
               c("call1()", "call2()"))
  expect_parse(parse_task_code("call1(); call2(1, 2, (3 + 4) + (5 + 6)); call3(4)"),
               c("call1()", "call2(1, 2, (3 + 4) + (5 + 6))", "call3(4)"))
})

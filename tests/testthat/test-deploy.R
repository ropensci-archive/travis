context("deploy")

test_that("parse tasks", {
  expect_equal(parse_task_env_value(" "), character())
  expect_equal(parse_task_env_value("call1() call2()"),
               c("call1()", "call2()"))
  expect_equal(parse_task_env_value("call1() call2(1, 2, (3 + 4)+(5 + 6)) call3(4)"),
               c("call1()", "call2(1, 2, (3 + 4)+(5 + 6))", "call3(4)"))
})

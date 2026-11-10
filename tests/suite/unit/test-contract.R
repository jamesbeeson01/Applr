# Every registered output type gets the shared trust tests from its demo case
# and its own mutations (helper-contract.R).

for (type in sort(ls(output_types))) {
  test_that(paste0(type, ": completeness"), {
    demo <- demo_entries(type)[1]
    mutated <- mutate_entry(demo[[1]], output_type(type)$mutations[[1]])
    expect_complete(type, c(demo, stats::setNames(list(mutated), paste0(names(demo), "_mutated"))))
  })

  test_that(paste0(type, ": sensitivity"), {
    expect_sensitive(type, demo_entries(type)[[1]])
  })

  test_that(paste0(type, ": stability"), {
    expect_stable(type, case_path(output_type(type)$demo))
  })
}

test_that("each type registered under types/ has a demo case and mutations", {
  for (type in ls(output_types)) {
    t <- output_type(type)
    expect_true(file.exists(case_path(t$demo)), label = paste(type, "demo case exists"))
    expect_gt(length(t$mutations), 0)
  }
})

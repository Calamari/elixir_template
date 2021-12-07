%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "config/"],
        excluded: []
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: true,
      checks: [
        {Credo.Check.Consistency.TabsOrSpaces, false},
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Design.TagFIXME, false},
        {Credo.Check.Refactor.Nesting, max_nesting: 3}
      ]
    }
  ]
}

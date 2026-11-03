# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-11-03

### Changed

- No changes to the gem itself. The first release published by the Release
  workflow through trusted publishing; 0.1.0 was pushed by hand because
  RubyGems.org now requires an asserted owner for a new gem's first push.
- CI and the Release workflow match graphql_tag_pluck's and use
  `actions/checkout@v7`, which runs on Node.js 24.
  ([#2](https://github.com/indigolain/graphql_tag_rbs/pull/2))

## [0.1.0] - 2026-11-03

### Added

- Generate RBS `variables`, `data`, and `response` types for each operation, and
  a `data` type for each fragment, from a graphql_tag_pluck (0.3.0 or later)
  operation list and a schema in SDL or introspection JSON.
- One `.rbs` file per source file, plus a shared file with the GraphQL error
  type and the enums and input objects the operations use.
- Validation of operations against the schema, with errors naming the
  operation's location.
- Options for the namespace, string or symbol keys, and custom scalar types.
- The `graphql_tag_rbs:generate` rake task, for Rails and other projects.

# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

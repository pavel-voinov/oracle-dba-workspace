CREATE OR REPLACE TYPE "SYS"."TCLOBNOTNULL" as object (
  buf       clob,
  static function ODCIAggregateInitialize (
    sctx in out nocopy TClobNotNull)
    return number,
  member function ODCIAggregateIterate(
    self in out nocopy TClobNotNull,
    value in clob)
    return number,
  member function ODCIAggregateTerminate (
    self in TClobNotNull,
    returnValue out nocopy clob,
    flags in number)
    return number,
  member function ODCIAggregateMerge (
    self in out nocopy TClobNotNull,
    ctx2 in TClobNotNull)
    return number,
  constructor function TClobNotNull
    return self as result
);
/
GRANT EXECUTE ON "SYS"."TCLOBNOTNULL" TO PUBLIC
/

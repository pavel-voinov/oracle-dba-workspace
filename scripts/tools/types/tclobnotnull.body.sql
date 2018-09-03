CREATE OR REPLACE TYPE BODY "SYS"."TCLOBNOTNULL" IS


  static function ODCIAggregateInitialize (
    sctx in out nocopy TClobNotNull)
    return number
  as
  begin
    sctx := TClobNotNull(null);
    return ODCIConst.Success;
  end ODCIAggregateInitialize;

  member function ODCIAggregateIterate (
    self in out nocopy TClobNotNull,
    value in clob)
    return number
  as
  begin
    if value is not null then
      self.buf := value;
    end if;
    return ODCIConst.Success;
  end ODCIAggregateIterate;

  member function ODCIAggregateTerminate (
    self in TClobNotNull,
    returnValue out nocopy clob,
    flags in number)
    return number
  as
  begin
    returnValue := trim(self.buf);
    return ODCIConst.Success;
  end ODCIAggregateTerminate;

  member function ODCIAggregateMerge (
    self in out nocopy TClobNotNull,
    ctx2 in TClobNotNull)
    return number
  as
  begin
    if ctx2.buf is not null then
      self.buf := ctx2.buf;
    end if;
    return ODCIConst.Success;
  end ODCIAggregateMerge;

  constructor function TClobNotNull
    return self as result
  as
  begin
    self.buf := empty_clob();

    return;
  end TClobNotNull;

end;
/

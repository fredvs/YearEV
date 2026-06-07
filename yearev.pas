program yearev;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef FPC}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
uses
 {$ifdef FPC}{$ifdef unix}cmem, cthreads,{$endif}{$endif} 
 msegui, msegraphics, msegraphutils, yearlist;
begin
 application.createform(tyearlistfo,yearlistfo);
 application.run;
end.

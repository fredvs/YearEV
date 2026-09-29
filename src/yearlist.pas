unit yearlist;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msedragglob,
 msegrids,msegridsglob,msekeyboard,sysutils,msestrings, msesimplewidgets,
 msebitmap, msetraywidget;
type
 tyearlistfo = class(tmseform)
   tstringgrid1: tstringgrid;
   tfacecomp1: tfacecomp;
   tframecomp2: tframecomp;
   timagelist5: timagelist;
   tbutton1: tbutton;
   ttraywidget1: ttraywidget;
   tbutton2: tbutton;
   tpopupmenu1: tpopupmenu;
   procedure keyup(const sender: twidget; var ainfo: keyeventinfoty);
   procedure onclose(const sender: TObject);
   procedure olc(const sender: tcustomgrid);
   procedure oncreate(const sender: TObject);
   procedure onl(const sender: TObject);
   procedure oact(const sender: TObject);
function Import : boolean;
function Load : boolean;
function Save : boolean;
   procedure onnow(const sender: TObject);
   procedure onmouse(const sender: twidget; var ainfo: mouseeventinfoty);
   procedure onhide(const sender: TObject);
   procedure onquit(const sender: TObject);
   procedure onfocus(const sender: TObject);
   procedure onloop(const sender: TObject);
 end;
function vg(y : Int64) : boolean;
const
  md : array[1..12] of byte = (31,29,31,30,31,30,31,31,30,31,30,31);

var
yearlistfo: tyearlistfo;
efyearlistfo : boolean = false;
onetime : boolean;
yearlistfile : string;
initYear, initMonth, initDay : Word;
isinit : boolean = false;
 
implementation
uses
 yearlist_mfm;
procedure tyearlistfo.keyup(const sender: twidget; var ainfo: keyeventinfoty);
begin
//if ainfo.key = key_Escape then Close;
end;

procedure tyearlistfo.onclose(const sender: TObject);
begin
Save;
end;

function vg(y : Int64) : boolean;
begin
Exit( (((y and 3) = 0) and (((y mod 100) <> 0))) or ((y mod 400) = 0) );
end;

procedure tyearlistfo.olc(const sender: tcustomgrid);
  var
      w : LongInt;
begin
w := tstringgrid1.clientwidth;
dec(w, 28);
if w < 1 + tstringgrid1.fixcols[-1].width then w := 1 + tstringgrid1.fixcols[-1].width;
if tstringgrid1.datacols[0].width + tstringgrid1.fixcols[-1].width <> w then
tstringgrid1.datacols[0].width := w - tstringgrid1.fixcols[-1].width + 25;
end;

procedure tyearlistfo.onl(const sender: TObject);
  var
    f, ff, c: LongInt;
	aDate : TDateTime;
	aYear, aMonth, aDay : Word; 
	OldShortDateFormat: string;
	OldDateSeparator: char;
	v:bytebool = false;
begin
{$WARNINGS OFF}
  c := 0;
  OldShortDateFormat := ShortDateFormat;
  OldDateSeparator := DateSeparator;
  ShortDateFormat := 'ddmmyyyy'; 
  DateSeparator := '/'; 
  DecodeDate(now, aYear, aMonth, aDay);
  caption :=  inttostr(aYear);
  
  // to determine the length of space for caption in menu
  tbutton1.caption := longdayNames[DayOfWeek(now)] + ' ' + 
                                         inttostr(aDay) + ' '+ longMonthNames[aMonth] +
                                         ' (' + IntToStr(aMonth) + ')';
   v := vg(aYear);

for f := 1 to 12 do
   begin
    tstringgrid1.rowcolorstate[c]:= 2;
    for ff := 1 to md[f] do begin
     if  (not v) and (f = 2) and (ff = 29) then 
        begin
        tstringgrid1.fixcols[-1].captions[c] :=  inttostr(ff) + ' ' + ShortMonthNames[f] + '(' + IntToStr(f) + ') n/a'; 
        tstringgrid1.rowcolorstate[c]:= 1;
        end else
        begin
        adate :=  StrToDate(inttostr(ff) + '/'+  IntToStr(f) + '/'+ inttostr(aYear));
        if (DayOfWeek(aDate) = 2) then tstringgrid1.rowcolorstate[c]:= 0;
        if (aDay = ff) and (aMonth = f) then tstringgrid1.rowcolorstate[c]:= 3;
        tstringgrid1.fixcols[-1].captions[c] :=
        ShortdayNames[DayOfWeek(aDate)] + ' ' + IntToStr(ff) + ' ' + ShortMonthNames[f] + '(' + IntToStr(f) + ')';
        end;
        Inc(c);
   end;     
    end;
    
 ShortDateFormat := OldShortDateFormat;
 DateSeparator := OldDateSeparator;    
{$WARNINGS ON}
end;

procedure tyearlistfo.oncreate(const sender: TObject);
begin
yearlistfile := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'yearlist.txt';
onetime := false;
if fileexists(yearlistfile) then Load else Import;
 DecodeDate(now, initYear, initMonth, initDay);
end;

procedure tyearlistfo.oact(const sender: TObject);
  var
      f : LongInt;
      g : gridcoordty;
      YY,MM,DD : Word;
begin
if onetime then exit;
g.row := 0;
DeCodeDate(Date,YY,MM,DD); 
for f := 1 to MM - 1 do g.row := g.row + md[f];
g.row := g.row + DD - 1;
    g.col := 0;
    tstringgrid1.showcell(g, cep_rowcentered, true);
        tstringgrid1.focuscell(g);
    tstringgrid1.datacols.selected[g] := true;
onetime := true;
end;

function tyearlistfo.Import : boolean;
var
    s  : msestring;
    be{, n} : boolean;
    f  : LongInt;
fn : msestring = '~.dr/status.sta';
fp : TextFile;
begin result := false;
//fn := homedir + fn;
if not fileexists(fn) then exit;
AssignFile(fp, fn);
FileMode := 0;
ReSet(fp);

be := false;
while not eof(fp) do begin
 readln(fp, s);
// n := system.Pos('values0=366', s) <> 0;
 if system.Pos('values0=366', s) <> 0 then begin be := true; continue; end;
 if not be then continue;
 for f := 0 to 365 do begin
	tstringgrid1[0].items[f] := Copy(s, 2, High(s));
	ReadLn(fp, s);
 end;
 break;
end;
CloseFile(fp);
end;

function tyearlistfo.Load : boolean;
var
    f  : LongInt;
    s  : msestring;
    yearlistfp : Text;
begin
AssignFile(yearlistfp, yearlistfile);
FileMode := 0;
ReSet(yearlistfp);
for f := 0 to 365 do begin
if eof(yearlistfp) then break;
ReadLn(yearlistfp, s);
tstringgrid1[0].items[f] := s;
end; {next}
CloseFile(yearlistfp);
end;

function tyearlistfo.Save : boolean;
var
    f  : LongInt;
    yearlistfp : Text;
begin
AssignFile(yearlistfp, yearlistfile);
FileMode := 1;
ReWrite(yearlistfp);
for f := 0 to 365 do begin
if f <> 365 then Writeln(yearlistfp, tstringgrid1[0].items[f]) else Write(yearlistfp, tstringgrid1[0].items[f]);
end;
CloseFile(yearlistfp);
end;

procedure tyearlistfo.onnow(const sender: TObject);
begin
onetime := false;
oact(sender);
end;

procedure tyearlistfo.onmouse(const sender: twidget;
               var ainfo: mouseeventinfoty);
begin
if (ainfo.eventkind = ek_buttonrelease) and (ainfo.button = mb_left) then
 begin
   if visible then visible := false else 
   begin
     visible := true;
     bringtofront;
   end;
   end;
end;

procedure tyearlistfo.onhide(const sender: TObject);
begin
visible := false;
end;

procedure tyearlistfo.onquit(const sender: TObject);
begin
save;
close;
end;

procedure tyearlistfo.onfocus(const sender: TObject);
var
aYear, aMonth, aDay : Word; 
begin
if isinit = true then
begin
//writeln('focused');
DecodeDate(now, aYear, aMonth, aDay);
if (initYear = aYear) and (initMonth = aMonth) and (initDay = aDay) then
else 
begin
//writeln('not even');
 caption :=  inttostr(aYear);
 tbutton1.caption := longdayNames[DayOfWeek(now)] + ' ' + 
                                         inttostr(aDay) + ' '+ longMonthNames[aMonth] +
                                       ' (' + IntToStr(aMonth) + ')';

 DecodeDate(now, initYear, initMonth, initDay);
end;
end;
end;

procedure tyearlistfo.onloop(const sender: TObject);
begin
isinit := true;
end;
end.
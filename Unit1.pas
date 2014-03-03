unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ToolWin, ExtCtrls, StdCtrls, Menus;

type
  APoint = array of TPoint;
  TForm1 = class(TForm)
    Img: TImage;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ImageList1: TImageList;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    PopupMenu1: TPopupMenu;
    add1: TMenuItem;
    delete1: TMenuItem;
    ListBox1: TListBox;
    ToolButton18: TToolButton;
    ColorBox1: TColorBox;
    ToolButton20: TToolButton;
    ToolButton19: TToolButton;
    procedure ClickOnFigure(number: byte);
    procedure ToolButton1Click(Sender: TObject);
    procedure ImgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure ConvertCoordinates(var point: TPoint; delphiCoordinates: boolean);
    procedure DeleteLastDrawedFigure;
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure NotFigureLastPushed;
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure MoveFigure(destination: string);
    procedure ReSizeFigure(zoom: double = 2.0; increase: boolean = true);
    procedure ToolButton17Click(Sender: TObject);
    procedure ToolButton16Click(Sender: TObject);
    procedure add1Click(Sender: TObject);
    procedure delete1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ReDrawAll;
    procedure DestroyFigures;
    procedure ClearCanvas;
    procedure ToolButton19Click(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TMyPoint = class
    coordinates: array of TPoint;
    center: TPoint;
    penWidth, layer: byte;
    color: TColor;
    constructor Create(point: TPoint; color: TColor = clBlack);
    destructor Destroy; override;
    procedure Draw(color: TColor; penWidth: byte = 3); virtual;
    procedure Clear;
    procedure Rotate(angle: integer = 20); virtual;
    procedure setCenter; virtual;
    procedure move(destination: string);
    procedure ReSize(zoom: double = 2.0; increase: boolean = true); virtual;
  end;
  TSquare = class(TMyPoint)
    oneSideSize, twoSideSize: integer;
    constructor Create(point: TPoint; color: TColor = clBlack; oneSideSize: integer = 20; twoSideSize: integer = 20);
    procedure setCenter; override;
  end;
  TRectangle = class(TSquare)
    constructor Create(point: TPoint; color: TColor = clBlack; oneSideSize: integer = 20; twoSideSize: integer = 40);
  end;
  TTriangle = class(TMyPoint)
    constructor Create(point: TPoint; color: TColor = clBlack);
    procedure setCenter; override;
  end;
  TCircle = class(TMyPoint)
    radius: integer;
    constructor Create(point: TPoint; color: TColor = clBlack; radius: integer = 20);
    procedure Draw(color: TColor; penWidth: byte = 3); override;
    procedure ReSize(zoom: double = 2.0; increase: boolean = true); override;
  end;
  TStar = class(TMyPoint)
    constructor Create(point: TPoint; color: TColor = clBlack);
    procedure setCenter; override;
  end;

const
  countOfTypeFigures = 6;
var
  Form1: TForm1;
  whatFigureLastPushed: byte;
  myPoint: TMyPoint;
  square: TSquare;
  rectangle: TRectangle;
  triangle: TTriangle;
  circle: TCircle;
  star: TStar;
  figures: TList;

implementation

uses Types;

{$R *.dfm}

{ TPoint }

constructor TMyPoint.Create(point: TPoint; color: TColor = clBlack);
const
  pointsCount = 2;
var
  i: byte;
begin
  SetLength(coordinates, pointsCount);
  for i := 0 to pointsCount - 1 do
  begin
    coordinates[i].X := point.X;
    coordinates[i].Y := point.Y;
  end;
  self.color := color;
end;

procedure TMyPoint.Clear;
begin
  self.Draw(clWhite);
end;

procedure TMyPoint.Draw(color: TColor; penWidth: byte = 3);
begin
  with Form1.Img.Canvas do
  begin
    Pen.Width := penWidth;
    Pen.Color := color;
    Polygon(coordinates);
  end;
end;

procedure TMyPoint.setCenter;
begin
  center.X := coordinates[0].X;
  center.Y := coordinates[0].Y;
end;

procedure TMyPoint.ReSize(zoom: double = 2.0; increase: boolean = true);
var
  i: byte;
  tempCoordinates: array of TPoint;
  isFigureOutOfCanvas: boolean;
begin
  Clear;
  setCenter;
  SetLength(tempCoordinates, Length(coordinates));
  isFigureOutOfCanvas := false;
  for i := 0 to Length(coordinates) - 1 do
  begin
    tempCoordinates[i].X := coordinates[i].X;
    tempCoordinates[i].Y := coordinates[i].Y;
  end;
  if not increase then zoom := 1 / zoom;
  for i := 0 to Length(coordinates) - 1 do
  begin
    if tempCoordinates[i].X > center.X then
      tempCoordinates[i].X := tempCoordinates[i].X + round(abs(tempCoordinates[i].X - center.X) * (zoom - 1))
    else if tempCoordinates[i].X < center.X then
      tempCoordinates[i].X := tempCoordinates[i].X - round(abs(tempCoordinates[i].X - center.X) * (zoom - 1));
    if tempCoordinates[i].Y > center.Y then
      tempCoordinates[i].Y := tempCoordinates[i].Y + round(abs(tempCoordinates[i].Y - center.Y) * (zoom - 1))
    else if tempCoordinates[i].Y < center.Y then
      tempCoordinates[i].Y := tempCoordinates[i].Y - round(abs(tempCoordinates[i].Y - center.Y) * (zoom - 1));
    if ((tempCoordinates[i].X * tempCoordinates[i].Y <= 0) or (tempCoordinates[i].X > Form1.Img.Width) or (tempCoordinates[i].Y > Form1.Img.Height)) then
    begin
      isFigureOutOfCanvas := true;
      break;
    end;
  end;
  if not isFigureOutOfCanvas then
    for i := 0 to Length(coordinates) - 1 do
    begin
      coordinates[i].X := tempCoordinates[i].X;
      coordinates[i].Y := tempCoordinates[i].Y;
    end;
  Form1.ReDrawAll;
end;

procedure TMyPoint.Rotate(angle: integer);
var
  i: byte;
  radian, t: double;
  x, y: integer;
  tempCoordinates: array of TPoint;
  isFigureOutOfCanvas: boolean;
begin
  Clear;
  setCenter;
  t := PI / angle;
  radian := PI / t;
  Form1.ConvertCoordinates(center, true);
  SetLength(tempCoordinates, Length(coordinates));
  isFigureOutOfCanvas := false;
  for i := 0 to Length(coordinates) - 1 do
  begin
    tempCoordinates[i].X := coordinates[i].X;
    tempCoordinates[i].Y := coordinates[i].Y;
  end;
  for i := 0 to Length(tempCoordinates) - 1 do
  begin
    Form1.ConvertCoordinates(tempCoordinates[i], true);
    x := tempCoordinates[i].X;
    y := tempCoordinates[i].Y;
    tempCoordinates[i].X := center.X + round((x - center.X) * cos(radian) - (y - center.Y) * sin(radian));
    tempCoordinates[i].Y := center.Y + round((x - center.X) * sin(radian) + (y - center.Y) * cos(radian));
    Form1.ConvertCoordinates(tempCoordinates[i], false);
    if ((tempCoordinates[i].X * tempCoordinates[i].Y <= 0) or (tempCoordinates[i].X > Form1.Img.Width) or (tempCoordinates[i].Y > Form1.Img.Height)) then
    begin
      isFigureOutOfCanvas := true;
      break;
    end;
  end;
  if not isFigureOutOfCanvas then
    for i := 0 to Length(coordinates) - 1 do
    begin
      coordinates[i].X := tempCoordinates[i].X;
      coordinates[i].Y := tempCoordinates[i].Y;
    end;
  Form1.ReDrawAll;
end;

destructor TMyPoint.Destroy;
begin
  Clear;
  inherited;
end;

procedure TMyPoint.move(destination: string);
  function LowerThanZero(a, b: integer; var c: boolean): boolean;
  begin
    if ((a * b <= 0) or (a > Form1.Img.Width) or (b > Form1.Img.Height)) then
      begin
        c := true;
        Result := true;
      end
    else begin
      c := false;
      Result := false;
    end;
  end;
const
  forMove = 10;
var
  i: byte;
  tempCoordinates: array of TPoint;
  isFigureOutOfCanvas: boolean;
begin
  Clear;
  SetLength(tempCoordinates, Length(coordinates));
  isFigureOutOfCanvas := false;
  for i := 0 to Length(coordinates) - 1 do
  begin
    tempCoordinates[i].X := coordinates[i].X;
    tempCoordinates[i].Y := coordinates[i].Y;
  end;
  if destination = 'up' then
    for i := 0 to Length(tempCoordinates) - 1 do
    begin
      tempCoordinates[i].Y := tempCoordinates[i].Y - forMove;
      if LowerThanZero(tempCoordinates[i].X, tempCoordinates[i].Y, isFigureOutOfCanvas) then break;
    end
  else if destination = 'right' then
    for i := 0 to Length(tempCoordinates) - 1 do
    begin
      tempCoordinates[i].X := tempCoordinates[i].X + forMove;
      if LowerThanZero(tempCoordinates[i].X, tempCoordinates[i].Y, isFigureOutOfCanvas) then break;
    end
  else if destination = 'down' then
    for i := 0 to Length(tempCoordinates) - 1 do
    begin
      tempCoordinates[i].Y := tempCoordinates[i].Y + forMove;
      if LowerThanZero(tempCoordinates[i].X, tempCoordinates[i].Y, isFigureOutOfCanvas) then break;
    end
  else if destination = 'left' then
    for i := 0 to Length(tempCoordinates) - 1 do
    begin
      tempCoordinates[i].X := tempCoordinates[i].X - forMove;
      if LowerThanZero(tempCoordinates[i].X, tempCoordinates[i].Y, isFigureOutOfCanvas) then break;
    end;
  if not isFigureOutOfCanvas then
    begin
      if destination = 'up' then for i := 0 to Length(tempCoordinates) - 1 do coordinates[i].Y := tempCoordinates[i].Y - forMove
      else if destination = 'right' then for i := 0 to Length(tempCoordinates) - 1 do coordinates[i].X := tempCoordinates[i].X + forMove
      else if destination = 'down' then for i := 0 to Length(tempCoordinates) - 1 do coordinates[i].Y := tempCoordinates[i].Y + forMove
      else if destination = 'left' then for i := 0 to Length(tempCoordinates) - 1 do coordinates[i].X := tempCoordinates[i].X - forMove;
    end;
  Form1.ReDrawAll;
end;

{ TSquare }

constructor TSquare.Create(point: TPoint; color: TColor = clBlack; oneSideSize: integer = 20; twoSideSize: integer = 20);
var
  tempCoordinates: array of TPoint;
  i: byte;
  isFigureOutOfCanvas: boolean;
begin
  SetLength(tempCoordinates, 4);
  self.color := color;
  self.oneSideSize := oneSideSize;
  self.twoSideSize := twoSideSize;
  tempCoordinates[0].X := point.X;
  tempCoordinates[0].Y := point.Y;
  tempCoordinates[1].X := tempCoordinates[0].X + oneSideSize;
  tempCoordinates[1].Y := tempCoordinates[0].Y;
  tempCoordinates[2].X := tempCoordinates[0].X + oneSideSize;
  tempCoordinates[2].Y := tempCoordinates[0].Y + twoSideSize;
  tempCoordinates[3].X := tempCoordinates[0].X;
  tempCoordinates[3].Y := tempCoordinates[0].Y + twoSideSize;
  isFigureOutOfCanvas := false;
  for i := 0 to Length(tempCoordinates) - 1 do
    if ((tempCoordinates[i].X * tempCoordinates[i].Y <= 0) or (tempCoordinates[i].X > Form1.Img.Width) or (tempCoordinates[i].Y > Form1.Img.Height)) then
    begin
      isFigureOutOfCanvas := true;
      break;
    end;
  SetLength(coordinates, 4);
  if not isFigureOutOfCanvas then for i := 0 to Length(coordinates) - 1 do
  begin
    coordinates[i].X := tempCoordinates[i].X;
    coordinates[i].Y := tempCoordinates[i].Y;
  end
  else Form1.NotFigureLastPushed;
end;

procedure TSquare.setCenter;
begin
  Form1.ConvertCoordinates(coordinates[0], true);
  Form1.ConvertCoordinates(coordinates[2], true);
  center.X := coordinates[0].X + (coordinates[2].X - coordinates[0].X) div 2;
  center.Y := coordinates[0].Y + (coordinates[2].Y - coordinates[0].Y) div 2;
  Form1.ConvertCoordinates(center, false);
  Form1.ConvertCoordinates(coordinates[0], false);
  Form1.ConvertCoordinates(coordinates[2], false);
end;

{ TRectangle }

constructor TRectangle.Create(point: TPoint; color: TColor = clBlack; oneSideSize: integer = 20; twoSideSize: integer = 40);
begin
  inherited Create(point, color, oneSideSize, twoSideSize);
end;

{ TTriangle }

constructor TTriangle.Create(point: TPoint; color: TColor = clBlack);
const
  forTriangle: integer = 50;
begin
  if ((point.X + forTriangle > Form1.Img.Width) or (point.X - forTriangle < 0) or (point.Y + forTriangle > Form1.Img.Height)) then
    Form1.NotFigureLastPushed
  else begin
    SetLength(coordinates, 3);
    self.color := color;
    coordinates[0].X := point.X;
    coordinates[0].Y := point.Y;
    coordinates[1].X := coordinates[0].X + forTriangle;
    coordinates[1].Y := point.Y + forTriangle;
    coordinates[2].X := point.X - forTriangle;
    coordinates[2].Y := point.Y + forTriangle;
  end;
end;

procedure TTriangle.setCenter;
begin
  Form1.ConvertCoordinates(coordinates[0], true);
  Form1.ConvertCoordinates(coordinates[2], true);
  center.X := coordinates[0].X;
  center.Y := coordinates[0].Y + (coordinates[2].Y - coordinates[0].Y) div 2;
  Form1.ConvertCoordinates(center, false);
  Form1.ConvertCoordinates(coordinates[0], false);
  Form1.ConvertCoordinates(coordinates[2], false);
end;

{ TCircle }

constructor TCircle.Create(point: TPoint; color: TColor = clBlack; radius: integer = 20);
begin
  if ((point.X - radius <= 0) or (point.X + radius >= Form1.Img.Width)
    or (point.Y - radius <= 0) or (point.Y + radius >= Form1.Img.Height)) then
    Form1.NotFigureLastPushed
  else begin
    inherited Create(point, color);
    self.radius := radius;
  end;
end;

procedure TCircle.Draw(color: TColor; penWidth: byte = 3);
begin
  with Form1.Img.Canvas do
  begin
    Pen.Width := penWidth;
    Pen.Color := color;
    Ellipse(coordinates[0].X - radius, coordinates[0].Y - radius, coordinates[0].X + radius, coordinates[0].Y + radius);
  end;
end;

procedure TCircle.ReSize(zoom: double = 2.0; increase: boolean = true);
var
  t: integer;
begin
  setCenter;
  Clear;
  if not increase then zoom := 1 / zoom;
  t := round(radius * abs(zoom));
  if ((coordinates[0].X - t <= 0) or (coordinates[0].X + t >= Form1.Img.Width)
    or (coordinates[0].Y - t <= 0) or (coordinates[0].Y + t >= Form1.Img.Height)) then
    Form1.NotFigureLastPushed
  else
    radius := round(radius * abs(zoom));
  Form1.ReDrawAll;
end;

{ TStar }

constructor TStar.Create(point: TPoint; color: TColor = clBlack);
var
  tempCoordinates: array of TPoint;
  i: byte;
  isFigureOutOfCanvas: boolean;
begin
  SetLength(tempCoordinates, 10);
  self.color := color;
  tempCoordinates[0].X := point.X;
  tempCoordinates[0].Y := point.Y;
  tempCoordinates[1].X := tempCoordinates[0].X + 30;
  tempCoordinates[1].Y := tempCoordinates[0].Y + 50;
  tempCoordinates[2].X := tempCoordinates[0].X + 50 * 2;
  tempCoordinates[2].Y := tempCoordinates[1].Y;
  tempCoordinates[3].X := tempCoordinates[1].X;
  tempCoordinates[3].Y := tempCoordinates[1].Y + 20;
  tempCoordinates[4].X := tempCoordinates[3].X + 10;
  tempCoordinates[4].Y := tempCoordinates[3].Y + 30;
  tempCoordinates[5].X := tempCoordinates[0].X;
  tempCoordinates[5].Y := tempCoordinates[0].Y + 80;
  tempCoordinates[6].X := tempCoordinates[0].X - (tempCoordinates[4].X - tempCoordinates[0].X);
  tempCoordinates[6].Y := tempCoordinates[4].Y;
  tempCoordinates[7].X := tempCoordinates[0].X - (tempCoordinates[3].X - tempCoordinates[0].X);
  tempCoordinates[7].Y := tempCoordinates[3].Y;
  tempCoordinates[8].X := tempCoordinates[0].X - (tempCoordinates[2].X - tempCoordinates[0].X);
  tempCoordinates[8].Y := tempCoordinates[2].Y;
  tempCoordinates[9].X := tempCoordinates[0].X - (tempCoordinates[1].X - tempCoordinates[0].X);
  tempCoordinates[9].Y := tempCoordinates[1].Y;
  isFigureOutOfCanvas := false;
  for i := 0 to Length(tempCoordinates) - 1 do
    if ((tempCoordinates[i].X * tempCoordinates[i].Y <= 0) or (tempCoordinates[i].X > Form1.Img.Width) or (tempCoordinates[i].Y > Form1.Img.Height)) then
    begin
      isFigureOutOfCanvas := true;
      break;
    end;
  SetLength(coordinates, 10);
  if not isFigureOutOfCanvas then for i := 0 to Length(coordinates) - 1 do
  begin
    coordinates[i].X := tempCoordinates[i].X;
    coordinates[i].Y := tempCoordinates[i].Y;
  end
  else Form1.NotFigureLastPushed;
end;

procedure TStar.setCenter;
begin
  Form1.ConvertCoordinates(coordinates[0], true);
  Form1.ConvertCoordinates(coordinates[5], true);
  center.X := coordinates[0].X;
  center.Y := coordinates[0].Y + (coordinates[5].Y - coordinates[0].Y) div 2;
  Form1.ConvertCoordinates(center, false);
  Form1.ConvertCoordinates(coordinates[0], false);
  Form1.ConvertCoordinates(coordinates[5], false);
end;

{ TForm1 }

procedure TForm1.ClickOnFigure(number: byte);
begin
  whatFigureLastPushed := number;
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  ClickOnFigure(StrToInt(Copy(TToolButton(Sender).Name, length(TToolButton(Sender).Name), 1)));
end;

// create and draw
procedure TForm1.ImgMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  point: TPoint;
  color: TColor;
begin
  point.X := X;
  point.Y := Y;
  color := ColorBox1.Selected;
  case whatFigureLastPushed of
    1:
      begin
        myPoint := TMyPoint.Create(point, color);
        myPoint.layer := ListBox1.ItemIndex;
        figures.Add(myPoint);
      end;
    2:
      begin
        triangle := TTriangle.Create(point, color);
        triangle.layer := ListBox1.ItemIndex;
        figures.Add(triangle);
       end;
    3:
      begin
        square := TSquare.Create(point, color);
        square.layer := ListBox1.ItemIndex;
        figures.Add(square);
       end;
    4:
      begin
        rectangle := TRectangle.Create(point, color);
        rectangle.layer := ListBox1.ItemIndex;
        figures.Add(rectangle);
       end;
    5:
      begin
        star := TStar.Create(point, color);
        star.layer := ListBox1.ItemIndex;
        figures.Add(star);
       end;
    6:
      begin
        circle := TCircle.Create(point, color);
        circle.layer := ListBox1.ItemIndex;
        if (Length(circle.coordinates) > 0) then
        begin
          figures.Add(circle);
        end else
          circle.Destroy;
       end;
  end;
  if whatFigureLastPushed > 0 then ReDrawAll;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  square.Rotate;
  rectangle.Rotate;
  triangle.Rotate;
  star.Rotate;
end;

procedure TForm1.ConvertCoordinates(var point: TPoint; delphiCoordinates: boolean);
begin
  point.Y := Form1.Img.Height div 2 - point.Y;
  if delphiCoordinates then
    point.X := point.X - Form1.Img.Width div 2
  else
    point.X := point.X + Form1.Img.Width div 2;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DestroyFigures;
  figures.Destroy;
end;

procedure TForm1.DeleteLastDrawedFigure;
begin
  if whatFigureLastPushed > 0 then
  begin
    figures.Delete(figures.Count - 1);
    case whatFigureLastPushed of
      1: myPoint.Destroy;
      2: triangle.Destroy;
      3: square.Destroy;
      4: rectangle.Destroy;
      5: star.Destroy;
      6: circle.Destroy;
    end;
    ReDrawAll;
  end;
end;

procedure TForm1.ToolButton8Click(Sender: TObject);
begin
  DeleteLastDrawedFigure;
  NotFigureLastPushed;
end;

procedure TForm1.ToolButton9Click(Sender: TObject);
begin
  case whatFigureLastPushed of
    2: triangle.Rotate;
    3: square.Rotate;
    4: rectangle.Rotate;
    5: star.Rotate;
  end;
end;

procedure TForm1.NotFigureLastPushed;
begin
  whatFigureLastPushed := 0;
end;

procedure TForm1.ToolButton10Click(Sender: TObject);
begin
  MoveFigure('up');
end;

procedure TForm1.ToolButton11Click(Sender: TObject);
begin
  MoveFigure('right');
end;

procedure TForm1.ToolButton12Click(Sender: TObject);
begin
  MoveFigure('down');
end;

procedure TForm1.ToolButton13Click(Sender: TObject);
begin
  MoveFigure('left')
end;

procedure TForm1.MoveFigure(destination: string);
begin
  case whatFigureLastPushed of
    1: myPoint.move(destination);
    2: triangle.move(destination);
    3: square.move(destination);
    4: rectangle.move(destination);
    5: star.move(destination);
    6: circle.move(destination);
  end;
end;

procedure TForm1.ReSizeFigure(zoom: double = 2.0; increase: boolean = true);
begin
  case whatFigureLastPushed of
    2: triangle.ReSize(zoom, increase);
    3: square.ReSize(zoom, increase);
    4: rectangle.ReSize(zoom, increase);
    5: star.ReSize(zoom, increase);
    6: circle.ReSize(zoom, increase);
  end;
end;

procedure TForm1.ToolButton17Click(Sender: TObject);
begin
  ReSizeFigure;
end;

procedure TForm1.ToolButton16Click(Sender: TObject);
begin
  ReSizeFigure(2.0, false);
end;

procedure TForm1.add1Click(Sender: TObject);
begin
  ListBox1.Items.Add(IntToStr(ListBox1.Items.Count + 1));
end;

procedure TForm1.delete1Click(Sender: TObject);
var
  i: integer;
begin
  if figures.Count > 0 then
  begin
    i := figures.Count - 1;
    while (i >= 0) do
    begin
      if TMyPoint(figures[i]).layer = ListBox1.ItemIndex then
      begin
        TMyPoint(figures[i]).Destroy;
        figures.Delete(i);
      end;
      i := i - 1;
   end;
   ReDrawAll;
   NotFigureLastPushed;
  end;
  if ListBox1.Items.Count > 1 then ListBox1.Items.Delete(ListBox1.ItemIndex);
  if ListBox1.Items.Count > 0 then
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  figures := TList.Create;
  ListBox1.ItemIndex := 0;
end;

procedure TForm1.ReDrawAll;
var
  i, j: byte;
begin
  if figures.Count > 0 then
    for i := 0 to ListBox1.Items.Count - 1 do
      for j := 0 to figures.Count - 1 do
        if TMyPoint(figures[j]).layer = i then
          TMyPoint(figures[j]).Draw(TMyPoint(figures[j]).color);
end;

procedure TForm1.DestroyFigures;
var
  i: integer;
begin
  if figures.Count > 0 then
  begin
    i := figures.Count - 1;
    while (i >= 0) do
    begin
      TMyPoint(figures[i]).Destroy;
      figures.Delete(i);
      i := i - 1;
   end;
  end;
end;

procedure TForm1.ClearCanvas;
begin
  Img.Canvas.FillRect(Img.Canvas.ClipRect);
end;

procedure TForm1.ToolButton19Click(Sender: TObject);
begin
  ClearCanvas;
  DestroyFigures;  
  NotFigureLastPushed;
end;

procedure TForm1.ColorBox1Change(Sender: TObject);
begin
  if figures.Count > 0 then TMyPoint(figures.Last).color := ColorBox1.Selected;
  ReDrawAll;
end;

end.
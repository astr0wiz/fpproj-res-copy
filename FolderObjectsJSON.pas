unit FolderObjects;

interface

uses SysUtils, Classes, fpJSON;


Type
  
  
  { -----------------------------------------------------------------------
    TFoldersItemFolderFilesItem
    -----------------------------------------------------------------------}
  
  TFoldersItemFolderFilesItem = class(TObject)
  Private
    FName : String;
  Public
    Constructor CreateFromJSON(AJSON : TJSONData); virtual;
    Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Function SaveToJSON : TJSONObject; overload;
    Procedure SaveToJSON(AJSON : TJSONObject); overload; virtual;
    Property Name : String Read fName Write fName;
  end;
  
  TFoldersItemFolderFiles = Array of TFoldersItemFolderFilesItem;

Procedure ClearArray(var anArray : TFoldersItemFolderFiles); overload;
Function CreateTFoldersItemFolderFiles(AJSON : TJSONData) : TFoldersItemFolderFiles;
Procedure SaveTFoldersItemFolderFilesToJSON(AnArray : TFoldersItemFolderFiles; AJSONArray : TJSONArray); overload;
Function SaveTFoldersItemFolderFilesToJSON(AnArray : TFoldersItemFolderFiles) : TJSONArray; overload;


Type
  
  
  { -----------------------------------------------------------------------
    TFoldersItemFolder
    -----------------------------------------------------------------------}
  
  TFoldersItemFolder = class(TObject)
  Private
    FPath : String;
    FFiles : TFoldersItemFolderFiles;
  Public
    Destructor Destroy; override;
    Constructor CreateFromJSON(AJSON : TJSONData); virtual;
    Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Function SaveToJSON : TJSONObject; overload;
    Procedure SaveToJSON(AJSON : TJSONObject); overload; virtual;
    Property Path : String Read fPath Write fPath;
    Property Files : TFoldersItemFolderFiles Read fFiles Write fFiles;
  end;
  
  
  { -----------------------------------------------------------------------
    TFoldersItem
    -----------------------------------------------------------------------}
  
  TFoldersItem = class(TObject)
  Private
    FFolder : TFoldersItemFolder;
  Public
    Destructor Destroy; override;
    Constructor CreateFromJSON(AJSON : TJSONData); virtual;
    Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Function SaveToJSON : TJSONObject; overload;
    Procedure SaveToJSON(AJSON : TJSONObject); overload; virtual;
    Property Folder : TFoldersItemFolder Read fFolder Write fFolder;
  end;
  
  TFolders = Array of TFoldersItem;

Procedure ClearArray(var anArray : TFolders); overload;
Function CreateTFolders(AJSON : TJSONData) : TFolders;
Procedure SaveTFoldersToJSON(AnArray : TFolders; AJSONArray : TJSONArray); overload;
Function SaveTFoldersToJSON(AnArray : TFolders) : TJSONArray; overload;


Type
  
  
  { -----------------------------------------------------------------------
    TMyObject
    -----------------------------------------------------------------------}
  
  TMyObject = class(TObject)
  Private
    FFolders : TFolders;
  Public
    Destructor Destroy; override;
    Constructor CreateFromJSON(AJSON : TJSONData); virtual;
    Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Function SaveToJSON : TJSONObject; overload;
    Procedure SaveToJSON(AJSON : TJSONObject); overload; virtual;
    Property Folders : TFolders Read fFolders Write fFolders;
  end;

implementation








{ -----------------------------------------------------------------------
  TFoldersItemFolderFilesItem
  -----------------------------------------------------------------------}


Constructor TFoldersItemFolderFilesItem.CreateFromJSON(AJSON : TJSONData);

begin
  Create();
  LoadFromJSON(AJSON);
end;

Procedure TFoldersItemFolderFilesItem.LoadFromJSON(AJSON : TJSONData);

var
  E : TJSONEnum;

begin
  for E in AJSON do
    begin
    case E.Key of
    'Name':
      Name:=E.Value.AsString;
    end;
    end;
end;
Function  TFoldersItemFolderFilesItem.SaveToJSON : TJSONObject;
begin
  Result:=TJSONObject.Create;
  Try
    SaveToJSON(Result);
  except
    FreeAndNil(Result);
    Raise;
  end;
end;


Procedure TFoldersItemFolderFilesItem.SaveToJSON(AJSON : TJSONObject);

begin
  AJSON.Add('Name',Name);
end;


Procedure ClearArray(Var anArray : TFoldersItemFolderFiles);

var
  I : integer;

begin
  For I:=0 to Length(anArray) do
    FreeAndNil(anArray[I]);
  SetLength(anArray,0);
End;


Function CreateTFoldersItemFolderFiles(AJSON : TJSONData) : TFoldersItemFolderFiles;

var
  I : integer;

begin
  SetLength(Result,AJSON.Count);
  For I:=0 to AJSON.Count-1 do
    Result[i]:=TFoldersItemFolderFilesItem.CreateFromJSON(AJSON.Items[i]);
End;


Function SaveTFoldersItemFolderFilesToJSON(AnArray : TFoldersItemFolderFiles) : TJSONArray;
begin
  Result:=TJSONArray.Create;
  Try
    SaveTFoldersItemFolderFilesToJSON(AnArray,Result);
  Except
    FreeAndNil(Result);
    Raise;
  end;
end;


Procedure SaveTFoldersItemFolderFilesToJSON(AnArray : TFoldersItemFolderFiles; AJSONArray : TJSONArray);

var
  I : integer;

begin
  For I:=0 to Length(AnArray)-1 do
    AJSONArray.Add(AnArray[i].SaveToJSON);
end;



{ -----------------------------------------------------------------------
  TFoldersItemFolder
  -----------------------------------------------------------------------}

Destructor TFoldersItemFolder.Destroy;

begin
  ClearArray(fFiles);
  inherited;
end;


Constructor TFoldersItemFolder.CreateFromJSON(AJSON : TJSONData);

begin
  Create();
  LoadFromJSON(AJSON);
end;

Procedure TFoldersItemFolder.LoadFromJSON(AJSON : TJSONData);

var
  E : TJSONEnum;

begin
  for E in AJSON do
    begin
    case E.Key of
    'Path':
      Path:=E.Value.AsString;
    'Files':
      Files:=CreateTFoldersItemFolderFiles(E.Value);
    end;
    end;
end;
Function  TFoldersItemFolder.SaveToJSON : TJSONObject;
begin
  Result:=TJSONObject.Create;
  Try
    SaveToJSON(Result);
  except
    FreeAndNil(Result);
    Raise;
  end;
end;


Procedure TFoldersItemFolder.SaveToJSON(AJSON : TJSONObject);

begin
  AJSON.Add('Path',Path);
  AJSON.Add('Files',SaveTFoldersItemFolderFilesToJSON(Files));
end;


{ -----------------------------------------------------------------------
  TFoldersItem
  -----------------------------------------------------------------------}

Destructor TFoldersItem.Destroy;

begin
  FreeAndNil(fFolder);
  inherited;
end;


Constructor TFoldersItem.CreateFromJSON(AJSON : TJSONData);

begin
  Create();
  LoadFromJSON(AJSON);
end;

Procedure TFoldersItem.LoadFromJSON(AJSON : TJSONData);

var
  E : TJSONEnum;

begin
  for E in AJSON do
    begin
    case E.Key of
    'Folder':
      Folder:=TFoldersItemFolder.CreateFromJSON(E.Value);
    end;
    end;
end;
Function  TFoldersItem.SaveToJSON : TJSONObject;
begin
  Result:=TJSONObject.Create;
  Try
    SaveToJSON(Result);
  except
    FreeAndNil(Result);
    Raise;
  end;
end;


Procedure TFoldersItem.SaveToJSON(AJSON : TJSONObject);

begin
  If Assigned(Folder) then
    AJSON.Add('Folder',Folder.SaveToJSON);
end;


Procedure ClearArray(Var anArray : TFolders);

var
  I : integer;

begin
  For I:=0 to Length(anArray) do
    FreeAndNil(anArray[I]);
  SetLength(anArray,0);
End;


Function CreateTFolders(AJSON : TJSONData) : TFolders;

var
  I : integer;

begin
  SetLength(Result,AJSON.Count);
  For I:=0 to AJSON.Count-1 do
    Result[i]:=TFoldersItem.CreateFromJSON(AJSON.Items[i]);
End;


Function SaveTFoldersToJSON(AnArray : TFolders) : TJSONArray;
begin
  Result:=TJSONArray.Create;
  Try
    SaveTFoldersToJSON(AnArray,Result);
  Except
    FreeAndNil(Result);
    Raise;
  end;
end;


Procedure SaveTFoldersToJSON(AnArray : TFolders; AJSONArray : TJSONArray);

var
  I : integer;

begin
  For I:=0 to Length(AnArray)-1 do
    AJSONArray.Add(AnArray[i].SaveToJSON);
end;



{ -----------------------------------------------------------------------
  TMyObject
  -----------------------------------------------------------------------}

Destructor TMyObject.Destroy;

begin
  ClearArray(fFolders);
  inherited;
end;


Constructor TMyObject.CreateFromJSON(AJSON : TJSONData);

begin
  Create();
  LoadFromJSON(AJSON);
end;

Procedure TMyObject.LoadFromJSON(AJSON : TJSONData);

var
  E : TJSONEnum;

begin
  for E in AJSON do
    begin
    case E.Key of
    'Folders':
      Folders:=CreateTFolders(E.Value);
    end;
    end;
end;
Function  TMyObject.SaveToJSON : TJSONObject;
begin
  Result:=TJSONObject.Create;
  Try
    SaveToJSON(Result);
  except
    FreeAndNil(Result);
    Raise;
  end;
end;


Procedure TMyObject.SaveToJSON(AJSON : TJSONObject);

begin
  AJSON.Add('Folders',SaveTFoldersToJSON(Folders));
end;

end.

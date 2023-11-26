Program FPProjResCopy;

{$mode objfpc}{$H+}

Uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  CustApp { you can add units after this },
  fpjsonrtti,
  SysUtils;

(*
------------------------------------------------------------------------------
FP Project Resource Copier
==========================
Copies project resources after compilation to target directory.  Very useful for
creating apps with resources that need to be placed into specific directories
in the deployment directory.

To use: Go to Project Options->Compiler Options->Compiler Commands.  Add the
following in the Command text box in the Execute After section:

    {path-to-app}/FPProjResCopy            (unix)
    {path-to-app}\FPProjResCopy.exe        (windows)

The app works by following the file specifications in a configuration file.
This config file must be named FPProjResCopy.config and it must reside in the
project's working directory (where the lpr, lpi, and lps files reside).

Config File Structure
=====================
This is a plain text, JSON-formatted file.  The structure is:

{
  "folderdata": [
    {
      "folder": {
        "path": "Resources",
        "files": [
          {
            "name": "file-1"
          },
          {
            "name": "file-2"
          },
          {
            "name": "file-3"
          }
        ]
      }
    },
    {
      "folder": {
        "path": "Resources/Images",
        "files": [
          {
            "name": "img-1.png"
          },
          {
            "name": "img-2.png"
          }
        ]
      }
    },
    {
      "folder": {
        "path": "Data/Cells/Dungeons",
        "files": [
          {
            "name": "dungeoncells.dat"
          }
        ]
      }
    },
    {
      "folder": {
        "path": "Backup"
      }
    },
    {
      "folder": {
        "path": "Screenshots",
        "files": [
        ]
      }
    }
  ]
}
*** REF: https://wiki.freepascal.org/Streaming_JSON
------------------------------------------------------------------------------
*)

Type

  TNameObject = Class(TCollectionItem)
  Private
    fName: String;
  Published
    Property Name: String read fName write fName;
  End;


  { TTemplateObject }

  TTemplateObject = Class(TCollectionItem)
  Private
    fPath:  String;
    fFiles: TCollection;
  Public
    Constructor Init;
    Destructor Destroy; Override;
  Published
    Property Path: String read fPath write fPath;
    Property Files: TCollection read fFiles write fFiles;
  End;

  (* ------------------------------------------------------------------
  This has been redesignated as just a Persistent object for testing
  ------------------------------------------------------------------ *)
  { TTemplateObjectSecundus }

  TTemplateObjectSecundus = Class(TPersistent)
  Private
    fPath:  String;
    fFiles: TCollection;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  Published
    Property Path: String read fPath write fPath;
    Property Files: TCollection read fFiles write fFiles;
  End;


  { TTemplateCollection }

  TTemplateCollection = Class(TPersistent)
  Private
    fFolders: TCollection;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  Published
    Property Folders: TCollection read fFolders write fFolders;
  End;

  (* ------------------------------------------------------------------
  This collection has only one TemplateObject
  ------------------------------------------------------------------ *)
  { TTemplateCollectionSecundus }

  TTemplateCollectionSecundus = Class(TPersistent)
  Private
    fFolder: TTemplateObjectSecundus;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  Published
    Property Folder: TTemplateObjectSecundus read fFolder write fFolder;
  End;


  { TProjResCopy }

  TProjResCopy = Class(TCustomApplication)
  Private
    FJsonData: String;
  Protected
    Procedure DoRun; Override;
  Public
    Constructor Create(TheOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure WriteHelp; Virtual;
    Procedure GetJsonString;
    Procedure TestJsonRead;
  End;

  Constructor TTemplateObjectSecundus.Create;
  Begin
    fFiles := TCollection.Create(TNameObject);
  End;

  Destructor TTemplateObjectSecundus.Destroy;
  Begin
    fFiles.Destroy;
    Inherited Destroy;
  End;

  Constructor TTemplateCollectionSecundus.Create;
  Begin
    fFolder := TTemplateObjectSecundus.Create;
  End;

  Destructor TTemplateCollectionSecundus.Destroy;
  Begin
    fFolder.Destroy;
    Inherited Destroy;
  End;

  { TTemplateCollection }

  Constructor TTemplateCollection.Create;
  Begin
    fFolders := TCollection.Create(TTemplateObject);
  End;

  Destructor TTemplateCollection.Destroy;
  Begin
    fFolders.Free;
    Inherited Destroy;
  End;

  { TTemplateObject }

  Constructor TTemplateObject.Init;
  Begin
    fFiles := TCollection.Create(TNameObject);
  End;

  Destructor TTemplateObject.Destroy;
  Begin
    fFiles.Free;
    Inherited Destroy;
  End;

  { TProjResCopy }

  Procedure TProjResCopy.DoRun;
  Var
    ErrorMsg: String;
  Begin
    // quick check parameters
    ErrorMsg := CheckOptions('h', 'help');
    If ErrorMsg <> '' Then
    Begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    End;

    // parse parameters
    If HasOption('h', 'help') Then
    Begin
      WriteHelp;
      Terminate;
      Exit;
    End;

    { add your program here }
    GetJsonString;
    TestJsonRead;

    ReadLn;
    // stop program loop
    Terminate;
  End;

  Constructor TProjResCopy.Create(TheOwner: TComponent);
  Begin
    Inherited Create(TheOwner);
    StopOnException := True;
  End;

  Destructor TProjResCopy.Destroy;
  Begin
    Inherited Destroy;
  End;

  Procedure TProjResCopy.WriteHelp;
  Begin
    { add your help code here }
    writeln('Usage: ', ExeName, ' -h');
  End;

  Procedure TProjResCopy.GetJsonString;
  Var
    T: TextFile;
    s: String;
  Begin
    AssignFile(T, 'test2.json');
    Reset(T);
    Repeat
      Readln(T, s);
      FJsonData := FJsonData + s;
    Until EOF(T);
    //    Writeln('************* JSON ***************');
    //    Writeln(FJsonData);
    //    Writeln('************* JSON ***************');
  End;

  Procedure TProjResCopy.TestJsonRead;
  Var
    DeStreamer: TJsonDestreamer;
    o:          TTemplateCollectionSecundus;
    fo: TTemplateObjectSecundus;
    no: TNameObject;
  Begin
    DeStreamer := TJsonDestreamer.Create(nil);
    o          := TTemplateCollectionSecundus.Create;
    Try
      DeStreamer.JSONToObject(FJsonData, o);

      Writeln('Path: ',o.Folder.Path);
      Writeln('Files:');
      for TCollectionItem(no) in o.Folder.Files do
        Writeln('  ',no.Name);

//      for TCollectionItem(fo) in o.Folders do
//        Writeln('Folder path: ', fo.Path);
    Finally
      o.Destroy;
      DeStreamer.Destroy;
    End;
  End;

Var
  Application: TProjResCopy;
Begin
  Application       := TProjResCopy.Create(nil);
  Application.Title:='FP Project Resource Copier';
  Application.Run;
  Application.Free;
End.

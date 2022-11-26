program test;

{$APPTYPE CONSOLE}

{$R *.res}

uses
	System.SysUtils,
	DUnitX.TestFramework,
	DUnitX.TestRunner,
	DUnitX.TestResult,
	DUnitX.Loggers.Console,
	DUnitX.Loggers.XML.NUnit,
	testsU in 'testsU.pas',
	phoneNumU in '../src/phoneNumU.pas';

var
    runner : ITestRunner;
    results : IRunResults;
    logger : ITestLogger;
    nunitLogger : ITestLogger;

begin
	try	
		//Create the runner
		runner := TDUnitX.CreateRunner;
		runner.UseRTTI := True;

		//tell the runner how we will log things
		if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
		begin
			logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
			runner.AddLogger(logger);
		end;

		nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
		runner.AddLogger(nunitLogger);

		//Run tests
		results := runner.Execute;

		System.Write('Done.. press <Enter> key to quit.');
		System.Readln;
	except
		on E: Exception do Writeln(E.ClassName, ': ', E.Message);
end;
end.

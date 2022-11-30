unit testsU;

interface

uses
    Dunitx.TestFramework;

type
    [TestFixture]
    phoneNumTestT = class
        [Test]
        [TestCase('Case 0: +55 49 95769-8674',  '+55 49 95769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 1: 55 49 95769-8674',   '55 49 95769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 2: 55 (49) 95769-8674', '55 (49) 95769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 3: 55 049 95769-8674',  '55 049 95769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 4: 55 049 957698674',   '55 049 957698674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 5: 55049957698674',     '55049957698674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 6: 49 95769-8674',      '49 95769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 7: 49 95769-8674',      '49 95769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 8: (49) 95769-8674',    '(49) 95769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 9: 049 95769-8674',     '049 95769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 10: 049 957698674',     '049 957698674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 11: 049957698674',      '049957698674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 12: 49 5769-8674',      '49 5769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 13: 49 5769-8674',      '49 5769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 14: (49) 5769-8674',    '(49) 5769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 15: 049 5769-8674',     '049 5769-8674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 16: 049 57698674',      '049 57698674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 17: 04957698674',       '04957698674,55,49,95769,8674,49 95769-8674,1')]
        [TestCase('Case 18: 554284184379',      '554284184379,55,42,98418,4379,42 98418-4379,1')]
        [TestCase('Case 18: 5542984184379',     '5542984184379,55,42,98418,4379,42 98418-4379,1')]
        procedure brazilTest(phone: string; expectedCountry: Integer; expectedNetwork: Integer; expectedNum1: Int64; expectedNum2: Int64; expectedFull: string; shouldPass: Integer);

        [Test]
        [TestCase('Case 0: +55 49 95769-8674',  '+55 49 95769-8674,55,49,957698674,0,55 49 957698674,1')]
        [TestCase('Case 1: 55 49 95769-8674',   '55 49 95769-8674,55,49,957698674,0,55 49 957698674,1')]
        [TestCase('Case 2: 55 (49) 95769-8674', '55 (49) 95769-8674,55,49,957698674,0,55 49 957698674,1')]
        [TestCase('Case 3: 55 049 95769-8674',  '55 049 95769-8674,55,049,957698674,0,55 49 957698674,1')]
        [TestCase('Case 4: 55 049 957698674',   '55 049 957698674,55,049,957698674,0,55 49 957698674,1')]
        [TestCase('Case 5: +55 49 95769 8674',  '+55 49 95769 8674,55,49,957698674,0,55 49 957698674,1')]
        [TestCase('Case 6: 55 49 95769 8674',   '55 49 95769 8674,55,49,957698674,0,55 49 957698674,1')]
        [TestCase('Case 7: 55 (49) 95769 8674', '55 (49) 95769 8674,55,49,957698674,0,55 49 957698674,1')]
        [TestCase('Case 8: 55 049 95769 8674',  '55 049 95769 8674,55,049,957698674,0,55 49 957698674,1')]
        [TestCase('Case 9: 55 049 957698674',   '55 049 957698674,55,049,957698674,0,55 49 957698674,1')]
        [TestCase('Case 10: +1 463 2957391279', '+1 463 2957391279,1,463,2957391279,0,1 463 2957391279,1')]
        [TestCase('Case 11: +374 2 2957',       '+374 2 2957,374,2,2957,0,374 2 2957,1')]
        [TestCase('Case 12: 213 227 85742957',  '213 227 85742957,213,227,85742957,0,213 227 85742957,1')]
        [TestCase('Case 13: 1 (227) 85742-957', '1 (227) 85742-957,1,227,85742957,0,1 227 85742957,1')]
        [TestCase('Case 14: 1-227-85742-957',   '1-227-85742-957,1,227,85742957,0,1 227 85742957,1')]
        procedure internacionalTest(phone: string; expectedCountry: Integer; expectedNetwork: Integer; expectedNum1: Int64; expectedNum2: Int64; expectedFull: string; shouldPass: Integer);

        [Test]
        [TestCase('Case 0: +55 49 95769-8674',  '+55 (49) 95769-8674,1')]
        procedure prettyPrintTest(phone: string; expectedFull: string; shouldPass: Integer);

        [Test]
        [TestCase('Case 0: (49) 95769-8674', '(49) 95769-8674,Santa Catarina,1')]
        [TestCase('Case 1: (22) 95769-8674', '(22) 95769-8674,Rio de Janeiro,1')]
        [TestCase('Case 2: (92) 95769-8674', '(92) 95769-8674,Amazonas,1')]
        [TestCase('Case 3: (80) 95769-8674', '(80) 95769-8674,Amazonas,0')]
        procedure getDDDRegionTest(phone: string; expectedDDDRegion: string; shouldPass: Integer);

        [Test]
        [TestCase('Case 0: 213 227 85742957', '213 227 85742957,Algeria,1')]
        [TestCase('Case 1: +374 2 2957', '+374 2 2957,Armenia,1')]
        [TestCase('Case 2: 1 (227) 85742-957', '1 (227) 85742-957,United States / Canada,1')]
        [TestCase('Case 3: 454 (49) 95769 8674', '454 (49) 95769 8674,United States / Canada,0')]
        procedure getCountryNameTest(phone: string; expectedCountryName: string; shouldPass: Integer);
    end;

implementation

uses
    phoneNumU,
    System.Classes,
    System.SysUtils,
    System.IOUtils;

procedure phoneNumTestT.prettyPrintTest(phone: string; expectedFull: string; shouldPass: Integer);
begin
    var p: phoneNumT; 
    try
        p := phoneNumT.CreateFromInternational(phone);
    except
        on E: Exception do raise;
    end;

    if shouldPass = 1 then
    begin
        Assert.AreEqual(expectedFull, p.prettyNumber, 'prettyNumber');
    end
    else
    begin
        Assert.AreNotEqual(expectedFull, p.prettyNumber, 'prettyNumber');
    end;
end;

procedure phoneNumTestT.getCountryNameTest(phone: string; expectedCountryName: string; shouldPass: Integer);
begin
    var p: phoneNumT; 
    try
        p := phoneNumT.CreateFromInternational(phone);
    except
        on E: Exception do raise;
    end;

    if shouldPass = 1 then
    begin
        var name: string := p.countryName; 
        Assert.AreEqual(expectedCountryName, name, 'expectedCountryName');
    end
    else
    begin
        Assert.WillRaise(
            procedure begin
                var name: string := p.countryName;   
            end,
            phoneE,
            'phoneE'
        );
    end;
end;

procedure phoneNumTestT.getDDDRegionTest(phone: string; expectedDDDRegion: string; shouldPass: Integer);
begin
    var p: phoneNumT; 
    try
        p := phoneNumT.CreateFromBrazil(phone);
    except
        on E: Exception do raise;
    end;

    if shouldPass = 1 then
    begin
        var region: string := p.dddRegion; 
        Assert.AreEqual(expectedDDDRegion, region, 'expectedDDDRegion');
    end
    else
    begin
        try
            var region: string := p.dddRegion; 
        except
            on E: Exception do
            begin
                Assert.Pass;      
            end;
        end;
    end;
end;

procedure phoneNumTestT.brazilTest(phone: string; expectedCountry: Integer; expectedNetwork: Integer; expectedNum1: Int64; expectedNum2: Int64; expectedFull: string; shouldPass: Integer);
begin
    var p: phoneNumT; 
    try
        p := phoneNumT.CreateFromBrazil(phone);
    except
        on E: Exception do raise;
    end;

    var country: integer := p.countryCode; 
    var network: integer := p.ddd; 
    var num1: Int64 := p.number; 
    var num2: Int64 := p.number2; 
    
    if shouldPass = 1 then
    begin
        Assert.AreEqual(expectedCountry, country, 'expectedCountry');
        Assert.AreEqual(expectedNetwork, network, 'expectedNetwork');
        Assert.AreEqual(expectedNum1   , num1, 'expectedNum1');
        Assert.AreEqual(expectedNum2   , num2, 'expectedNum2');
        Assert.AreEqual(expectedFull   , p.brazilNumber, 'expectedFull');
    end
    else
    begin
        Assert.AreNotEqual(expectedCountry, country, 'expectedCountry');
        Assert.AreNotEqual(expectedNetwork, network, 'expectedNetwork');
        Assert.AreNotEqual(expectedNum1   , num1, 'expectedNum1');
        Assert.AreNotEqual(expectedNum2   , num2, 'expectedNum2');
        Assert.AreNotEqual(expectedFull   , p.brazilNumber, 'expectedFull');
    end;
end;

procedure phoneNumTestT.internacionalTest(phone: string; expectedCountry: Integer; expectedNetwork: Integer; expectedNum1: Int64; expectedNum2: Int64; expectedFull: string; shouldPass: Integer);
begin
    var p: phoneNumT; 
    try
        p := phoneNumT.CreateFromInternational(phone);
    except
        on E: Exception do raise;
    end;

    var country: integer := p.countryCode; 
    var network: integer := p.networkCarrierCode; 
    var num1: Int64 := p.subscriptionNumber; 
    var num2: Int64 := p.subscriptionNumber2; 
    
    if shouldPass = 1 then
    begin
        Assert.AreEqual(expectedCountry, country, 'expectedCountry');
        Assert.AreEqual(expectedNetwork, network, 'expectedNetwork');
        Assert.AreEqual(expectedNum1   , num1, 'expectedNum1');
        Assert.AreEqual(expectedNum2   , num2, 'expectedNum2');
        Assert.AreEqual(expectedFull   , p.internationalNumber, 'expectedFull');
    end
    else
    begin
        Assert.AreNotEqual(expectedCountry, country, 'expectedCountry');
        Assert.AreNotEqual(expectedNetwork, network, 'expectedNetwork');
        Assert.AreNotEqual(expectedNum1   , num1, 'expectedNum1');
        Assert.AreNotEqual(expectedNum2   , num2, 'expectedNum2');
        Assert.AreNotEqual(expectedFull   , p.internationalNumber, 'expectedFull');
    end;
end;

initialization
    TDUnitX.RegisterTestFixture(phoneNumTestT);
end.

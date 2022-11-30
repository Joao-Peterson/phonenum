unit phoneNumU;

interface

uses 
    System.SysUtils,
    System.Classes;

type

    // phone number class, uses the E.212 ITU standard
    // https://www.itu.int/rec/T-REC-E.212-201609-I/en
    phoneNumT = class
        protected
        // country code. Ex: +55, +1
        countryCodeF: Integer;
        // network carrier code. Ex: 49, 555
        networkCodeF: Integer;
        // subscription number. Ex: 984169457, 4832626838, 756757
        subscriptionCodeF: Int64;
        subscriptionCode2F: Int64;

        function getInternationalNumber(): string;
        function getPrettyPrint(): string;
        function getBrazilNumber(): string;
        function getCountryName(): string;
        function getDDDName(): string;

        public
        // IMSI format
        // country code. Ex: +55, +1
        property countryCode: Integer read countryCodeF write countryCodeF;
        property countryName: String read getCountryName;
        // network carrier code. Ex: 49, 555
        property networkCarrierCode: Integer read networkCodeF write networkCodeF;
        // subscription number. Ex: 984169457, 4832626838, 756757
        property subscriptionNumber: Int64 read subscriptionCodeF write subscriptionCodeF;
        property subscriptionNumber2: Int64 read subscriptionCode2F write subscriptionCode2F;

        // formatted number. Ex: 55 49 984562379
        property internationalNumber: String read getInternationalNumber;
        // formatted number. Ex: +55 (49) 98456-2379
        property prettyNumber: String read getPrettyPrint;

        // Brazil number format
        // DDD. Ex: 49, 42
        property ddd: Integer read networkCodeF write networkCodeF;
        // region name associated with the number. Ex: São paulo, Santa catarina
        property dddRegion: String read getDDDName;
        // subscription number part 1. Ex: 98456-
        property number: Int64 read subscriptionCodeF write subscriptionCodeF;
        // subscription number part 1. Ex: -2379
        property number2: Int64 read subscriptionCode2F write subscriptionCode2F;
        // formatted number. Ex: (49) 98456-2379
        property brazilNumber: String read getBrazilNumber;

        // create phoneNum from string, specific for brazil. Number can have a 55 or not in front. If a 9 is not present in front of the subscription number, it will be added
        constructor CreateFromBrazil(phone: string);
        // create phoneNum from string. Must have a country code
        constructor CreateFromInternational(phone: string);
        destructor Destroy(); override;
    end;

    phoneE = class(Exception);

implementation

uses
    System.RegularExpressions;

const 
    brazilRegex         = '^\+?(55)?\s?\(?(0?\d{1,2})\)?\s?9?(\d{4})[-\s]?(\d{4})$';
    internationalRegex  = '^\+?(\d{1,3})[\s\-]?\(?(\d{1,3})\)?[\s\-]?([\d\-\s]{3,10})';

var 
    dddCodesList: TStringList;
    dddNamesList: TStringList;
    countryCodes: TStringList;
    countryNames: TStringList;

function phoneNumT.getCountryName(): string;
begin
    var code := countryCodes.IndexOf(countryCodeF.ToString());

    if code = -1 then raise phoneE.Create('country code: [' + countryCodeF.ToString() + '] is a invalid code or unknown');

    Result := countryNames.KeyNames[code];
end;

function phoneNumT.getDDDName(): string;
begin
    var code := dddCodesList.IndexOf(networkCodeF.ToString());

    if code = -1 then raise phoneE.Create('DDD code: [' + networkCodeF.ToString() + '] is a invalid DDD or unknown');

    Result := dddNamesList.KeyNames[code];
end;

function phoneNumT.getPrettyPrint(): string;
begin
    Result := Format('+%d (%d) %d-%d', [countryCodeF, networkCodeF, subscriptionCodeF, subscriptionCode2F]);
end;

function phoneNumT.getBrazilNumber(): string;
begin
    Result := Format('%d %d-%d', [networkCodeF, subscriptionCodeF, subscriptionCode2F]);
end;

function phoneNumT.getInternationalNumber(): string;
begin
    if subscriptionCode2F = 0 then
        Result := Format('%d %d %d', [countryCodeF, networkCodeF, subscriptionCodeF])
    else
        Result := Format('%d %d %d%d', [countryCodeF, networkCodeF, subscriptionCodeF, subscriptionCode2F]);
end;

function matchPhone(phone: string; regex: string): TMatch;
begin
    if phone.IsEmpty() then raise phoneE.Create('phone passed is empty');

    var match: TMatch;
    try
        match := TRegEx.Match(phone, regex);
    except
        on E: Exception do raise phoneE.Create('error trying to match phone number. Message: ' + E.Message);
    end;

    if not match.Success then raise phoneE.Create('no match was found for the phone');

    Result := match;
end;

constructor phoneNumT.CreateFromBrazil(phone: string);
begin
    inherited Create();    

    var match: TMatch;
    try
        match := matchPhone(phone, brazilRegex);
    except
        on E: phoneE do raise;
        on E: Exception do phoneE.Create('unexpected exception. Message: ' + E.Message);
    end;

    var i: integer;
    var country: integer := -1;

    if match.Groups.Count < 5 then raise phoneE.Create('regex on brazil phone number didn''t found all values.');
    if match.Groups.Count > 5 then raise phoneE.Create('regex on brazil phone number found extra values. Invalid brazil''s number.');

    for i := 0 to match.Groups.Count-1 do
    begin
        case i of
            1: begin                                                                                                        // country
                if not match.Groups.Item[i].Value.IsEmpty then
                    country := match.Groups.Item[i].Value.ToInteger
                else
                    country := 55;
            end;

            2: networkCodeF := match.Groups.Item[i].Value.ToInteger;                                                        // ddd
            3: begin                                                                                                        // num1
                var num1: string := '9' + match.Groups.Item[i].Value;
                subscriptionCodeF := num1.ToInteger;            
            end;
            4: subscriptionCode2F := match.Groups.Item[i].Value.ToInteger;                                                  // num2
        end;
    end;

    if country <> 55 then raise phoneE.Create('country passed is not from brazil. Country code 55 not found.');
    if subscriptionCodeF.ToString.Length <> 5 then raise phoneE.Create('phone number first numeric part has length different than 5. number: ['+ IntToStr(subscriptionCodeF) +']. Invalid brazil''s number');
    if subscriptionCode2F.ToString.Length <> 4 then raise phoneE.Create('phone number second numeric part has length different than 4. number: ['+ IntToStr(subscriptionCode2F) +']. Invalid brazil''s number');
    if subscriptionCode2F = 0 then raise phoneE.Create('phone number doesn''t have a second numeric part like: "94454-5745". Invalid brazil''s number');

    countryCodeF := 55;
end;

constructor phoneNumT.CreateFromInternational(phone: string);
begin
    inherited Create();    

    var match: TMatch;
    try
        match := matchPhone(phone, internationalRegex);
    except
        on E: phoneE do raise;
        on E: Exception do phoneE.Create('unexpected exception. Message: ' + E.Message);
    end;

    if match.Groups.Count < 4 then raise phoneE.Create('regex on international phone number didn''t found enough values.');
    if match.Groups.Count > 5 then raise phoneE.Create('regex on international phone number found too many values. Invalid international''s number.');

    var i: integer;
    for i := 0 to match.Groups.Count - 1 do
    begin
        case i of
            1: countryCodeF := match.Groups.Item[i].Value.ToInteger;
            2: networkCodeF := match.Groups.Item[i].Value.ToInteger;
            3: begin
                var val: String := match.Groups.Item[i].Value;
                val := val.Replace('-', '');
                val := val.Replace(' ', '');
                subscriptionCodeF := StrToInt64(val);
            end;

            4: begin
                var val: String := match.Groups.Item[i].Value;
                val := val.Replace('-', '');
                val := val.Replace(' ', '');
                subscriptionCode2F := StrToInt64(val);
            end;

        end;
    end;
end;

destructor phoneNumT.Destroy();
begin
    inherited Destroy();
end;

initialization
    dddCodesList := TStringList.Create();
    dddCodesList.Add('11');
    dddCodesList.Add('12');
    dddCodesList.Add('13');
    dddCodesList.Add('14');
    dddCodesList.Add('15');
    dddCodesList.Add('16');
    dddCodesList.Add('17');
    dddCodesList.Add('18');
    dddCodesList.Add('19');
    dddCodesList.Add('21');
    dddCodesList.Add('22');
    dddCodesList.Add('24');
    dddCodesList.Add('27');
    dddCodesList.Add('28');
    dddCodesList.Add('31');
    dddCodesList.Add('32');
    dddCodesList.Add('33');
    dddCodesList.Add('34');
    dddCodesList.Add('35');
    dddCodesList.Add('37');
    dddCodesList.Add('38');
    dddCodesList.Add('41');
    dddCodesList.Add('42');
    dddCodesList.Add('43');
    dddCodesList.Add('44');
    dddCodesList.Add('45');
    dddCodesList.Add('46');
    dddCodesList.Add('47');
    dddCodesList.Add('48');
    dddCodesList.Add('49');
    dddCodesList.Add('51');
    dddCodesList.Add('52');
    dddCodesList.Add('53');
    dddCodesList.Add('54');
    dddCodesList.Add('55');
    dddCodesList.Add('61');
    dddCodesList.Add('62');
    dddCodesList.Add('64');
    dddCodesList.Add('63');
    dddCodesList.Add('65');
    dddCodesList.Add('66');
    dddCodesList.Add('67');
    dddCodesList.Add('68');
    dddCodesList.Add('69');
    dddCodesList.Add('71');
    dddCodesList.Add('73');
    dddCodesList.Add('74');
    dddCodesList.Add('75');
    dddCodesList.Add('77');
    dddCodesList.Add('79');
    dddCodesList.Add('79');
    dddCodesList.Add('81');
    dddCodesList.Add('89');
    dddCodesList.Add('82');
    dddCodesList.Add('83');
    dddCodesList.Add('84');
    dddCodesList.Add('85');
    dddCodesList.Add('88');
    dddCodesList.Add('86');
    dddCodesList.Add('87');
    dddCodesList.Add('91');
    dddCodesList.Add('93');
    dddCodesList.Add('94');
    dddCodesList.Add('92');
    dddCodesList.Add('97');
    dddCodesList.Add('95');
    dddCodesList.Add('96');
    dddCodesList.Add('98');
    dddCodesList.Add('99');

    dddNamesList := TStringList.Create();
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('São Paulo');           
    dddNamesList.Add('Rio de Janeiro');      
    dddNamesList.Add('Rio de Janeiro');      
    dddNamesList.Add('Rio de Janeiro');      
    dddNamesList.Add('Espirito Santo');      
    dddNamesList.Add('Espirito Santo');      
    dddNamesList.Add('Minas Gerais');        
    dddNamesList.Add('Minas Gerais');        
    dddNamesList.Add('Minas Gerais');        
    dddNamesList.Add('Minas Gerais');        
    dddNamesList.Add('Minas Gerais');        
    dddNamesList.Add('Minas Gerais');        
    dddNamesList.Add('Minas Gerais');        
    dddNamesList.Add('Paraná');              
    dddNamesList.Add('Paraná');              
    dddNamesList.Add('Paraná');              
    dddNamesList.Add('Paraná');              
    dddNamesList.Add('Paraná');              
    dddNamesList.Add('Paraná');              
    dddNamesList.Add('Santa Catarina');      
    dddNamesList.Add('Santa Catarina');      
    dddNamesList.Add('Santa Catarina');      
    dddNamesList.Add('Rio Grande do Sul');   
    dddNamesList.Add('Rio Grande do Sul');   
    dddNamesList.Add('Rio Grande do Sul');   
    dddNamesList.Add('Rio Grande do Sul');   
    dddNamesList.Add('Rio Grande do Sul');   
    dddNamesList.Add('Distrito Federal');    
    dddNamesList.Add('Goiás');               
    dddNamesList.Add('Goiás');               
    dddNamesList.Add('Tocantins');           
    dddNamesList.Add('Mato Grosso');         
    dddNamesList.Add('Mato Grosso');         
    dddNamesList.Add('Mato Grosso do Sul');  
    dddNamesList.Add('Acre');                
    dddNamesList.Add('Rondônia');            
    dddNamesList.Add('Bahia');               
    dddNamesList.Add('Bahia');               
    dddNamesList.Add('Bahia');               
    dddNamesList.Add('Bahia');               
    dddNamesList.Add('Bahia');               
    dddNamesList.Add('Bahia');               
    dddNamesList.Add('Sergipe');             
    dddNamesList.Add('Pernambuco');          
    dddNamesList.Add('Pernambuco');          
    dddNamesList.Add('Alagoas');             
    dddNamesList.Add('Paraiba');             
    dddNamesList.Add('Rio Grande do Norte'); 
    dddNamesList.Add('Ceará');               
    dddNamesList.Add('Ceará');               
    dddNamesList.Add('Piauí');               
    dddNamesList.Add('Piauí');               
    dddNamesList.Add('Pará');                
    dddNamesList.Add('Pará');                
    dddNamesList.Add('Pará');                
    dddNamesList.Add('Amazonas');            
    dddNamesList.Add('Amazonas');            
    dddNamesList.Add('Roraima');             
    dddNamesList.Add('Amapá');               
    dddNamesList.Add('Maranhão');            
    dddNamesList.Add('Maranhão');           

    countryCodes := TStringList.Create();
    countryCodes.Add('1');
    countryCodes.Add('7');
    countryCodes.Add('20');
    countryCodes.Add('27');
    countryCodes.Add('30');
    countryCodes.Add('31');
    countryCodes.Add('32');
    countryCodes.Add('33');
    countryCodes.Add('34');
    countryCodes.Add('36');
    countryCodes.Add('39');
    countryCodes.Add('40');
    countryCodes.Add('41');
    countryCodes.Add('43');
    countryCodes.Add('44');
    countryCodes.Add('45');
    countryCodes.Add('46');
    countryCodes.Add('47');
    countryCodes.Add('48');
    countryCodes.Add('49');
    countryCodes.Add('51');
    countryCodes.Add('52');
    countryCodes.Add('53');
    countryCodes.Add('54');
    countryCodes.Add('55');
    countryCodes.Add('56');
    countryCodes.Add('57');
    countryCodes.Add('58');
    countryCodes.Add('60');
    countryCodes.Add('61');
    countryCodes.Add('62');
    countryCodes.Add('63');
    countryCodes.Add('64');
    countryCodes.Add('65');
    countryCodes.Add('66');
    countryCodes.Add('81');
    countryCodes.Add('82');
    countryCodes.Add('84');
    countryCodes.Add('86');
    countryCodes.Add('90');
    countryCodes.Add('91');
    countryCodes.Add('92');
    countryCodes.Add('93');
    countryCodes.Add('94');
    countryCodes.Add('95');
    countryCodes.Add('98');
    countryCodes.Add('211');
    countryCodes.Add('212');
    countryCodes.Add('213');
    countryCodes.Add('216');
    countryCodes.Add('218');
    countryCodes.Add('220');
    countryCodes.Add('221');
    countryCodes.Add('222');
    countryCodes.Add('223');
    countryCodes.Add('224');
    countryCodes.Add('225');
    countryCodes.Add('226');
    countryCodes.Add('227');
    countryCodes.Add('228');
    countryCodes.Add('229');
    countryCodes.Add('230');
    countryCodes.Add('231');
    countryCodes.Add('232');
    countryCodes.Add('233');
    countryCodes.Add('234');
    countryCodes.Add('235');
    countryCodes.Add('236');
    countryCodes.Add('237');
    countryCodes.Add('238');
    countryCodes.Add('239');
    countryCodes.Add('240');
    countryCodes.Add('241');
    countryCodes.Add('242');
    countryCodes.Add('243');
    countryCodes.Add('244');
    countryCodes.Add('245');
    countryCodes.Add('246');
    countryCodes.Add('247');
    countryCodes.Add('248');
    countryCodes.Add('249');
    countryCodes.Add('250');
    countryCodes.Add('251');
    countryCodes.Add('252');
    countryCodes.Add('253');
    countryCodes.Add('254');
    countryCodes.Add('255');
    countryCodes.Add('256');
    countryCodes.Add('257');
    countryCodes.Add('258');
    countryCodes.Add('260');
    countryCodes.Add('261');
    countryCodes.Add('262');
    countryCodes.Add('263');
    countryCodes.Add('264');
    countryCodes.Add('265');
    countryCodes.Add('266');
    countryCodes.Add('267');
    countryCodes.Add('268');
    countryCodes.Add('269');
    countryCodes.Add('290');
    countryCodes.Add('291');
    countryCodes.Add('297');
    countryCodes.Add('298');
    countryCodes.Add('299');
    countryCodes.Add('350');
    countryCodes.Add('351');
    countryCodes.Add('352');
    countryCodes.Add('353');
    countryCodes.Add('354');
    countryCodes.Add('355');
    countryCodes.Add('356');
    countryCodes.Add('357');
    countryCodes.Add('358');
    countryCodes.Add('359');
    countryCodes.Add('370');
    countryCodes.Add('371');
    countryCodes.Add('372');
    countryCodes.Add('373');
    countryCodes.Add('374');
    countryCodes.Add('375');
    countryCodes.Add('376');
    countryCodes.Add('377');
    countryCodes.Add('378');
    countryCodes.Add('379');
    countryCodes.Add('380');
    countryCodes.Add('381');
    countryCodes.Add('382');
    countryCodes.Add('383');
    countryCodes.Add('385');
    countryCodes.Add('386');
    countryCodes.Add('387');
    countryCodes.Add('389');
    countryCodes.Add('420');
    countryCodes.Add('421');
    countryCodes.Add('423');
    countryCodes.Add('500');
    countryCodes.Add('501');
    countryCodes.Add('502');
    countryCodes.Add('503');
    countryCodes.Add('504');
    countryCodes.Add('505');
    countryCodes.Add('506');
    countryCodes.Add('507');
    countryCodes.Add('508');
    countryCodes.Add('509');
    countryCodes.Add('590');
    countryCodes.Add('591');
    countryCodes.Add('592');
    countryCodes.Add('593');
    countryCodes.Add('594');
    countryCodes.Add('595');
    countryCodes.Add('596');
    countryCodes.Add('597');
    countryCodes.Add('598');
    countryCodes.Add('670');
    countryCodes.Add('672');
    countryCodes.Add('673');
    countryCodes.Add('674');
    countryCodes.Add('675');
    countryCodes.Add('676');
    countryCodes.Add('677');
    countryCodes.Add('678');
    countryCodes.Add('679');
    countryCodes.Add('680');
    countryCodes.Add('681');
    countryCodes.Add('682');
    countryCodes.Add('683');
    countryCodes.Add('685');
    countryCodes.Add('686');
    countryCodes.Add('687');
    countryCodes.Add('688');
    countryCodes.Add('689');
    countryCodes.Add('690');
    countryCodes.Add('691');
    countryCodes.Add('692');
    countryCodes.Add('800');
    countryCodes.Add('808');
    countryCodes.Add('850');
    countryCodes.Add('852');
    countryCodes.Add('853');
    countryCodes.Add('855');
    countryCodes.Add('856');
    countryCodes.Add('870');
    countryCodes.Add('878');
    countryCodes.Add('880');
    countryCodes.Add('881');
    countryCodes.Add('882');
    countryCodes.Add('883');
    countryCodes.Add('886');
    countryCodes.Add('888');
    countryCodes.Add('960');
    countryCodes.Add('961');
    countryCodes.Add('962');
    countryCodes.Add('963');
    countryCodes.Add('964');
    countryCodes.Add('965');
    countryCodes.Add('966');
    countryCodes.Add('967');
    countryCodes.Add('968');
    countryCodes.Add('970');
    countryCodes.Add('971');
    countryCodes.Add('972');
    countryCodes.Add('973');
    countryCodes.Add('974');
    countryCodes.Add('975');
    countryCodes.Add('976');
    countryCodes.Add('977');
    countryCodes.Add('979');
    countryCodes.Add('992');
    countryCodes.Add('993');
    countryCodes.Add('994');
    countryCodes.Add('995');
    countryCodes.Add('996');
    countryCodes.Add('998');

    countryNames := TStringList.Create();
    countryNames.Add('United States / Canada');
    countryNames.Add('Russia');
    countryNames.Add('Egypt');
    countryNames.Add('South Africa');
    countryNames.Add('Greece');
    countryNames.Add('Netherlands');
    countryNames.Add('Belgium');
    countryNames.Add('France');
    countryNames.Add('Spain');
    countryNames.Add('Hungary');
    countryNames.Add('Italy');
    countryNames.Add('Romania');
    countryNames.Add('Switzerland');
    countryNames.Add('Austria');
    countryNames.Add('United Kingdom');
    countryNames.Add('Denmark');
    countryNames.Add('Sweden');
    countryNames.Add('Norway');
    countryNames.Add('Poland');
    countryNames.Add('Germany');
    countryNames.Add('Peru');
    countryNames.Add('Mexico');
    countryNames.Add('Cuba');
    countryNames.Add('Argentina');
    countryNames.Add('Brazil');
    countryNames.Add('Chile / Easter Island ');
    countryNames.Add('Colombia');
    countryNames.Add('Venezuela');
    countryNames.Add('Malaysia');
    countryNames.Add('Australia');
    countryNames.Add('Indonesia');
    countryNames.Add('Philippines');
    countryNames.Add('New Zealand / Pitcairn Islands/ Chatham Island');
    countryNames.Add('Singapore');
    countryNames.Add('Thailand');
    countryNames.Add('Japan');
    countryNames.Add('Korea, South');
    countryNames.Add('Vietnam');
    countryNames.Add('China');
    countryNames.Add('Turkey');
    countryNames.Add('India');
    countryNames.Add('Pakistan');
    countryNames.Add('Afghanistan');
    countryNames.Add('Sri Lanka');
    countryNames.Add('Myanmar');
    countryNames.Add('Iran');
    countryNames.Add('South Sudan');
    countryNames.Add('Morocco');
    countryNames.Add('Algeria');
    countryNames.Add('Tunisia');
    countryNames.Add('Libya');
    countryNames.Add('Gambia');
    countryNames.Add('Senegal');
    countryNames.Add('Mauritania');
    countryNames.Add('Mali');
    countryNames.Add('Guinea');
    countryNames.Add('Ivory Coast (Côte d''Ivoire)');
    countryNames.Add('Burkina Faso');
    countryNames.Add('Niger');
    countryNames.Add('Togo');
    countryNames.Add('Benin');
    countryNames.Add('Mauritius');
    countryNames.Add('Liberia');
    countryNames.Add('Sierra Leone');
    countryNames.Add('Ghana');
    countryNames.Add('Nigeria');
    countryNames.Add('Chad');
    countryNames.Add('Central African Republic');
    countryNames.Add('Cameroon');
    countryNames.Add('Cape Verde');
    countryNames.Add('São Tomé and Príncipe');
    countryNames.Add('Equatorial Guinea');
    countryNames.Add('Gabon');
    countryNames.Add('Congo');
    countryNames.Add('Congo, Democratic Republic of the');
    countryNames.Add('Angola');
    countryNames.Add('Guinea-Bissau');
    countryNames.Add('Diego Garcia');
    countryNames.Add('Ascension');
    countryNames.Add('Seychelles');
    countryNames.Add('Sudan');
    countryNames.Add('Rwanda');
    countryNames.Add('Ethiopia');
    countryNames.Add('Somalia');
    countryNames.Add('Djibouti');
    countryNames.Add('Kenya');
    countryNames.Add('Tanzania');
    countryNames.Add('Uganda');
    countryNames.Add('Burundi');
    countryNames.Add('Mozambique');
    countryNames.Add('Zambia');
    countryNames.Add('Madagascar');
    countryNames.Add('Réunion');
    countryNames.Add('Zimbabwe');
    countryNames.Add('Namibia');
    countryNames.Add('Malawi');
    countryNames.Add('Lesotho');
    countryNames.Add('Botswana');
    countryNames.Add('Eswatini');
    countryNames.Add('Comoros');
    countryNames.Add('Saint Helena');
    countryNames.Add('Eritrea');
    countryNames.Add('Aruba');
    countryNames.Add('Faroe Islands');
    countryNames.Add('Greenland');
    countryNames.Add('Gibraltar');
    countryNames.Add('Portugal');
    countryNames.Add('Luxembourg');
    countryNames.Add('Ireland');
    countryNames.Add('Iceland');
    countryNames.Add('Albania');
    countryNames.Add('Malta');
    countryNames.Add('Cyprus');
    countryNames.Add('Finland');
    countryNames.Add('Bulgaria');
    countryNames.Add('Lithuania');
    countryNames.Add('Latvia');
    countryNames.Add('Estonia');
    countryNames.Add('Moldova');
    countryNames.Add('Armenia');
    countryNames.Add('Belarus');
    countryNames.Add('Andorra');
    countryNames.Add('Monaco');
    countryNames.Add('San Marino');
    countryNames.Add('Vatican City State (Holy See)');
    countryNames.Add('Ukraine');
    countryNames.Add('Serbia');
    countryNames.Add('Montenegro');
    countryNames.Add('Kosovo');
    countryNames.Add('Croatia');
    countryNames.Add('Slovenia');
    countryNames.Add('Bosnia and Herzegovina');
    countryNames.Add('North Macedonia');
    countryNames.Add('Czech Republic');
    countryNames.Add('Slovakia');
    countryNames.Add('Liechtenstein');
    countryNames.Add('Falkland Islands / South Georgia and the South Sandwich Islands');
    countryNames.Add('Belize');
    countryNames.Add('Guatemala');
    countryNames.Add('El Salvador');
    countryNames.Add('Honduras');
    countryNames.Add('Nicaragua');
    countryNames.Add('Costa Rica');
    countryNames.Add('Panama');
    countryNames.Add('Saint Pierre and Miquelon');
    countryNames.Add('Haiti');
    countryNames.Add('Guadeloupe / Saint Barthélemy / Saint Martin (France)');
    countryNames.Add('Bolivia');
    countryNames.Add('Guyana');
    countryNames.Add('Ecuador');
    countryNames.Add('French Guiana');
    countryNames.Add('Paraguay');
    countryNames.Add('French Antilles / Martinique ');
    countryNames.Add('Suriname');
    countryNames.Add('Uruguay');
    countryNames.Add('East Timor (Timor-Leste)');
    countryNames.Add('Australian External Territories');
    countryNames.Add('Brunei Darussalam');
    countryNames.Add('Nauru');
    countryNames.Add('Papua New Guinea');
    countryNames.Add('Tonga');
    countryNames.Add('Solomon Islands');
    countryNames.Add('Vanuatu');
    countryNames.Add('Fiji');
    countryNames.Add('Palau');
    countryNames.Add('Wallis and Futuna');
    countryNames.Add('Cook Islands');
    countryNames.Add('Niue');
    countryNames.Add('Samoa');
    countryNames.Add('Kiribati');
    countryNames.Add('New Caledonia');
    countryNames.Add('Tuvalu');
    countryNames.Add('French Polynesia');
    countryNames.Add('Tokelau');
    countryNames.Add('Micronesia, Federated States of');
    countryNames.Add('Marshall Islands');
    countryNames.Add('International Freephone Service (UIFN)');
    countryNames.Add('International Shared Cost Service (ISCS)');
    countryNames.Add('Korea, North');
    countryNames.Add('Hong Kong');
    countryNames.Add('Macau');
    countryNames.Add('Cambodia');
    countryNames.Add('Laos');
    countryNames.Add('Inmarsat SNAC');
    countryNames.Add('Universal Personal Telecommunications (UPT)');
    countryNames.Add('Bangladesh');
    countryNames.Add('Global Mobile Satellite System (GMSS)');
    countryNames.Add('International Networks');
    countryNames.Add('International Networks');
    countryNames.Add('Taiwan');
    countryNames.Add('Telecommunications for Disaster Relief by OCHA');
    countryNames.Add('Maldives');
    countryNames.Add('Lebanon');
    countryNames.Add('Jordan');
    countryNames.Add('Syria');
    countryNames.Add('Iraq');
    countryNames.Add('Kuwait');
    countryNames.Add('Saudi Arabia');
    countryNames.Add('Yemen');
    countryNames.Add('Oman');
    countryNames.Add('Palestine, State of');
    countryNames.Add('United Arab Emirates');
    countryNames.Add('Israel');
    countryNames.Add('Bahrain');
    countryNames.Add('Qatar');
    countryNames.Add('Bhutan');
    countryNames.Add('Mongolia');
    countryNames.Add('Nepal');
    countryNames.Add('International Premium Rate Service');
    countryNames.Add('Tajikistan');
    countryNames.Add('Turkmenistan');
    countryNames.Add('Azerbaijan');
    countryNames.Add('Georgia');
    countryNames.Add('Kyrgyzstan');
    countryNames.Add('Uzbekistan');
    
finalization
    dddCodesList.Destroy();
    dddNamesList.Destroy();
    countryCodes.Destroy();
    countryNames.Destroy();

end.
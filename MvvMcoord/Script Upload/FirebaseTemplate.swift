import Foundation
import Firebase
import FirebaseDatabase

class FirebaseTemplate {
    
    enum DataTypeEnum: String {
        case filters = "filters", subfilters = "subfilters", subfiltersByItem = "subfiltersByItem", itemsBySubfilter = "itemsBySubfilter", priceByItemId = "priceByItemId", prefetch = "prefetch", catalogIds = "catalogIds"
    }
    
    //var brands = ["Abby", "ABODIE", "Acasta"]
    var brands = ["Abby", "ABODIE", "Acasta", "ACCENT woman", "ACTRUS", "AdaGatti", "Adelante", "Adele", "Adelin Fostayn", "Adidas", "adL", "Adrianna Papell", "ADZHEDO", "Aelite", "AFFARI", "Aftershock", "Aika", "AJIOTAJE", "Ajour", "AKHMADULLINADREAMS", "AKIMBO", "Aksamit", "AlGO", "Alain Murati", "ALBAMODA", "ALBARI", "Aldani", "Alego", "ALEGRO", "Aleksandra", "ALEKSANDRAVANUSHINA", "ALEKSANDRIA", "Alena Alenkina", "Alena Stepurina", "Alena Wise", "Alen Ola", "Alex DANDY", "Alex Mazurin", "ALEXENDRA", "Alfa", "ALFOX", "ALIA", "Alice Street", "Alicja", "AlinaAssi", "Alira", "Alisa", "Alisia Fiori", "ALIXSTORY", "Alkis", "allescape", "AllaBuone", "Allezye", "Allys", "ALMAGORES", "Almando Melado", "Almila lux", "Alpama", "alpecora", "Alphamoda", "Alpine PRO", "Altra Natura", "ALWERO", "AMOne", "AMADEUSFAMILY", "Amado Barcelona", "Amaia", "Amanda", "AMAREA", "Amarti", "AMAZINGMOM", "AMAZONE", "Amelia Lux", "AMELIE", "American Outfitters", "Amie", "AMOND STORY", "ANAFLO", "ANAITMHEYAN", "Analili", "Anamalia", "Anastasia Kovall", "Anastasia Nadyktova", "ANASTASIAPETROVA", "ANASTASIAVERESCHAGINA", "Anastasya Barsukova", "Ancora", "ANDETTA", "ANDOVERS", "Andre", "ANDREACROCETTA", "ANDREWKLOFF", "ANELI", "ANGELVI", "An Gela", "Angela Ricci", "Angelika Marchioni", "Angelo Bonetti", "Angels NeverDie", "ANGY", "ANIMAGEMELLA", "Animals", "ANKITA", "Ankoli", "AnnaG", "ANNAMAKARENKO", "Anna Rachele Jeans", "annafara", "ANNBORG", "Anora", "AnpomenA", "ANRI", "ANROstore", "Antony Alison", "ANUR", "Anybodysblonde", "AnyMo", "APART", "ApiApoli", "Apparele", "APRELLE", "April", "AQUAMaritime", "ARAIDA", "ARBORVITAE", "Archeologie", "ARCOBALENO", "Ardamina", "ARDATEX", "Arefeva", "Arella", "ARGENT", "ARIABABY", "ARIADNA", "Arisha", "Aristokratia", "ARjen", "ARKADY", "ArmaniJeans", "Artribbon", "ARTESSAHOME", "Artex", "Artwizard", "Ascool", "Ashilda", "ASOLINDA", "Astron", "ASVfashiondesign", "aTani", "ATE", "AtelierAmaranth", "AtelierRevolver", "ATELITA", "AtosLombardini", "AudreyRight", "AURACOLOR", "AURELIE", "AURORA", "AURORAMOS", "AVEMOD", "AVERI", "AVGUSTATRAVKINA", "Avigal", "AVILA", "AVORY", "Avrora", "Avtandil", "AXParis", "AylinStories", "AyselAmiraslanova", "AZiAR", "B Co", "B H", "B SDenim", "Blesk", "byoung", "Ba Sh", "Babylon", "Bagard", "Balloon Paris", "Balloon Москва", "BALSAKO", "Bandolera", "Baon", "Barboleta", "Barcelonica", "BARKHAT", "Barmariska", "BARSU", "BARTELLI", "Basia", "Bast", "Bastioni", "Batistafashion", "Bayonne", "BAZZARO", "BBDakota", "Bdvaro", "Becara", "befirst", "bein", "BEINBLOOM", "beMAIN", "be_in", "Beautymammy", "bebe", "Befamilylook", "Befree", "Begood", "Behcetti", "Belsiluet", "BELARUSACHKA", "BELKA", "Bellakareema", "BellArt", "Bellis", "BELLOBELICCI", "bellovera", "Belweiss", "Berenis", "Beresta", "BergaModa", "Bergans", "BeriBegi", "BERKANA", "BERKLINE", "BERONI", "Berrak", "BertaMuzis", "BestTAILOR", "Best Best", "Bestia", "BETTALEME", "BettyBarclay", "BEYZAS", "Bezaliya", "Bezko", "BFCOLLECTION", "BGLFASHIONGROUP", "BGN", "BidenkovS", "BIGSTAR", "bilcee", "BILLABONG", "Binita", "BinitraBini", "BioConnection", "Bip Bip", "Biquette", "BIRRIN", "Bize", "BIZZARRO", "BLACKART", "BlackQueenCollection", "BlackStarWear", "BlackSpade", "BlagoF", "blans", "Blatant", "BLAUZ", "Blend", "Blonde Brunette", "BLOOMcollection", "Bluedeep", "BlueSeven", "BLUGIRL", "BlugirlFolies", "BoldandBeautiful", "Boleko", "BonaDea", "BONAPARTE", "Bonali", "BON AR", "BONA TEX", "bonda", "Bondiano", "BONICA", "Bonita", "BonneFemme", "Bonsui", "Borboleta", "Bordo", "Bornsoon", "BORODINAKSENIA", "BOVONA", "Braccialini", "BRAINWEAR", "Bramante", "BrandGG", "BRANDWOMEN", "BRASHOV", "Brassorti", "BRAVO", "Bridesteam", "BRIVIDO", "Broadway", "BRUSNIKA", "BSB", "BSBY", "BUARO", "Buduarium", "Budumamoy", "BULMER", "BUONO", "BUREAU", "Burlesco", "BURLO", "Burvin", "BUVER", "BuyMe", "ByBelka", "BYFLORA", "BYGAKOFF", "BZR", "CHIC", "Cacharel", "Caitline", "Calista", "CalvinKlein", "Camart", "Camelia", "Camellia", "Camelot", "CanNong", "Capaalii", "Capris", "Capriz", "Capsuletta", "Captain", "Caractere", "Caramell", "CARDO", "Cariba", "Carica", "CARLA", "CarlaRuiz", "CarloBottichelli", "CARRYALLEN", "Cascatto", "CATHERINES", "Catsproduction", "Cauris", "Cavandoli", "Cavo", "CAZADOR", "CeMeLondon", "Cellini", "CeMe", "Cerezo", "CHAMPION", "CHAPURIN", "Charmante", "Charuel", "ChateauFleur", "Chernika", "Chersa", "ChicdeFemme", "Chicmama", "Chicwear", "Chillytime", "CHKALOV", "ChopA", "ChrisBerY", "Christobal", "Churinga", "CITYSTAR", "CLABIN", "CLAIR", "ClassCavalli", "ClassInternational", "ClassicStyle", "Classik t", "Claw", "CLEO", "CLEVERWEAR", "CLEVERwoman", "CLEVERwomanstudio", "CnScollection", "Cobra", "Coccapani", "Coclo", "Cocomio", "COCOS", "Coctelle", "Colabear", "Colambetta", "Coline", "Colins", "CollettoBianco", "Collex", "Columbia", "Colveri", "Comfi", "Comma", "Com Mix", "CoMode", "Comodita", "COMPAGNIAITALIANA", "CompaniaFantastica", "Concept", "ConceptClub", "CONDRADELUXE", "Confident", "Consowear", "Container", "CONTEElegant", "CONVER", "Converse", "Corleoneexclusive", "Cosmo", "COST", "Cotton Silk", "COTTONLUX", "COUCHEL", "CRAZYDAISY", "Cream", "CREDO", "CrewClothing", "CristinaGavioli", "Crystaleyez", "Cubus", "Cultme", "CUTE", "CUVEE", "D M", "DS", "DSGlamoure", "DVA", "Dimma", "Daina", "Dairos", "Dalinnica", "DamKapriz", "DanielaDivine", "Danuta", "DANYA", "Dappe", "DARBOURSTORE", "DariaKrasovskaya", "Darinelly", "DarissaFashion", "DARS", "DashaGauser", "DASTI", "DavLiss", "DAYS", "DCComics", "DCShoes", "DeaFiori", "DEDEAN", "DeEmili", "DEESSE", "Defile", "DelFiore", "DeLight", "DeLis", "DeLiscollection", "DemFashion", "Demeni", "DEMMA", "DEMURYA", "DEMURYACONCEPT", "deni lu", "DeniRi", "DenRaven", "DEPARY", "Dept", "Derry", "Desam", "DeScossa", "Deseo", "Desigual", "devita", "DEVORE", "Devur", "DEZULA", "Dgavakhir", "Diana", "DIANAtextile", "DIANIDA", "Diazz", "Diesel", "Dilvin", "DIMANEU", "DinoChizari", "Dinoel", "Diona", "Dioni", "Dios", "DiSASH", "DiSORELLE", "DISORELLE", "DIVAS", "DIVERSE", "DiViM", "DIXIE", "DizzyWay", "DKNY", "DLYS", "DOCTORE", "Dolcewella", "Domashacollection", "DomenicoCroci", "DOMNA", "DonatellaViaRoma", "DonatelloViorano", "DonDup", "DonnaBambinna", "DonnaSaggia", "DonnedaSogno", "DORA", "DORISStreich", "DorogoBogato", "DorothysHome", "DoubleZero", "Dragotsennaya", "DreamWorld", "Dreamers", "Dreamscometrue", "DreskovaLyubov", "DressmebyMariyaLokot", "DressedinGreen", "DressForYou", "DressHunt", "Dressing", "DRESS TOP", "DRSDeerose", "Drykorn", "Drywash", "DSHE", "DSTrend", "DuckyStyle", "Dursi", "DUYING", "DVOREC", "ELevy", "EagleCollection", "EASINESS", "EASYWEAR", "Effect style", "EGMARRA", "E go", "EKATERINAKUNGUROVA", "ElFaMei", "ElTone", "Ela", "ELARDIS", "EleanBoutique", "Electrastyle", "Eleganc", "Elegance", "Elegancestyle", "ELEGANZA", "Elema", "Element", "ELEMENTS", "ELEN", "Elena", "ElenaAndriadi", "ElenaCollection", "ELENAFEDEL", "ElenaKulikova", "ElenaMiro", "ElenaShipilova", "ElenaShumilo", "ElenaKleid", "ElenaTex", "Eleonor", "Eleonor", "Elestrai", "ElevenParis", "ELFBERG", "EligoCod", "ELIS", "EliseevaOlesya", "ELITbyter hakobyan", "Ella Cathy", "ElleLand", "ELLIFSTORY", "ELNY", "ELSstudio", "Elvinjontex", "Elza", "Emansipe", "EMBLEM", "EMDI", "EmiFilini", "Emilia", "EMILLIEN", "EMKAFASHION", "EMMY", "EMO", "EmoibyEmonite", "EmporioArmani", "emse", "Encantado", "Enchanter", "Endea", "Eniland", "EniMode", "EnnaLevoni", "EOLA", "EPATAGE", "ErnestoKhachatyryan", "erteks", "EseMos", "Esley", "ESMINA", "ESPRIT", "ESQUIRE", "ESSA", "ESSMY", "ESTASI", "Etincelle", "ETOL", "Eunishop", "EUROMAMA", "EVABERTEN", "EvaDavidova", "EvaFranco", "EvaGraffova", "EvaManchini", "EvaMenda", "Eva Kristi", "EVAcollection", "EvaGraffova", "Evarina", "EVENESS", "Evercode", "EVERIS", "EverydaybyTamary", "EVGENIASTYLE", "EVKRATA", "EVRIKA", "EwaMoretti", "EXPLOSION", "EXPRESSDRESS", "EZANNA", "FdeF", "F T", "F K", "F", "FABIEN", "FactoryFashion", "FAIBISZAB", "FainaTveritina", "Fairly", "FAITHCONNEXION", "FamilyColors", "FamilyHouse", "FANNI", "FansyWay", "Fantosh", "Faqmarket", "Farfalla", "FartFavorita", "FASCONARIA", "FASHION", "Fashion", "FashionPirveli", "FashionUp", "FashionLoveStory", "FataFutur", "FATTI", "Favori", "FaysoSvaro", "Fazo R", "FEECLOT", "Feelologia", "Feelook", "FEM", "Feminelle", "Femme", "FENZE", "Fervente", "FEST", "Festa", "Festival", "Fever", "Fiato", "Fichissimo", "FIFFO", "FifiLakres", "FIGL", "Fileo", "FILGRAND", "FILL", "FinnFlare", "FiorellaRubino", "FioridiLara", "Firma", "FirstYoungDaring", "FLAMES", "Flammber", "Flarry", "Flashin", "FLEURETTA", "Flip", "Flo Jo", "Flori", "FLUFFYSHOPS", "Fly", "FlyGirl", "Foggy", "Folgore", "FORYOU", "FORLIFE", "Formalab", "FORMULAJOVEN", "Fornarina", "FORS", "Fortitta", "FORTUNA", "Forus", "Forward", "FORZAVIVA", "FourLine", "FOX", "Fox Orchids", "FOXBERRY", "FOXS", "FOXY", "FRACOMINA", "Frambo", "FRANCESCALUCINI", "FrancoVello", "FrankFashion", "FrankLyman", "FRANKLINANDMARSHALL", "FRAUcollection", "FrauStoch", "FredPerry", "Freddy", "FreeageFashion", "FreeSpirit", "FRENCHHINT", "FREYJA", "Friis", "Frio", "FROGGI", "Fronzoli", "FULGIDO", "FUNKYRIDE", "Furiel", "FUSION", "FuturOutfit", "Fuzer", "Gabriela", "Gaib", "Galaktika", "GalantAS", "GalinaVasilyeva", "GALION", "GallantTouch", "GANT", "GARCIA", "GARMETRIC", "GAS", "Gaudi", "Gebbe", "Gelco", "Gemko", "Gemkoplussize", "GENERALIMPRESSIONS", "GENESIS", "GENEVIE", "Genstaro", "GEPUR", "Gerbera", "GerryWeber", "GertmAn", "GETCLO", "GGStyle", "GianiF", "GIANISERRA", "GILLI", "GingerandSoul", "GioBoutique", "GIRASOLE", "GiuliaRossi", "GIZIA", "Gizzey", "GJFashion", "GKGermanKuch", "Glamcasual", "GlamGoddess", "Glamorous", "Glamour", "Glamzon", "Glauri", "Glem", "GloryStreet", "Gloss", "GoddessLondon", "Goddiva", "Goddivaplus", "GoldChicChili", "GoldenStyle", "GOLDI", "GoldyMama", "GOLUB", "GOOSEberry", "Gorchica", "GordaBella", "GOTSHER", "Gottex", "Gouache", "GRACE", "GRACEwomanwear", "GRAFINIA", "GrandGrom", "GRANDAZA", "GrandUA", "GRAZANA", "GREENCOAST", "GreenTara", "Gregory", "GREYCAT", "GreyTex", "GRIOL", "Grishko", "Grizas", "G SEL", "GSFR", "G STARRAW", "GUESS", "GukaJalie", "GULIETTA", "GuliGuli", "Gygess", "HTH", "Hammond", "HandyWear", "Hanna", "Happiness", "HappyAnn", "HappyHood", "Happychoice", "HARTWEAR", "HAUBER", "HAYS", "HEAD", "HEAVYTOOLS", "Hegler", "Heine", "Helena", "HELLOMODA", "HelloRussia", "HellyHansen", "HELMIDGE", "HenryCottons", "Hestollina", "HEYMAMA", "HIART", "HI", "HokkoBa", "HolyBloom", "HomeSecrets", "HomeStyle", "HomeLike", "homewearbylulu", "Horosha", "HOSSINTROPIA", "HotelParticulier", "HunnyMammy", "HustlerLingerie", "Ihomewear", "Ilovemum", "ILOVESHOPPING", "IBW", "ICEMODA", "Icepeak", "ICHI", "IconGirl", "Iconoclast", "idekka", "IDIALEN", "IGLENA", "IGN", "IHOMELUX", "IICEL", "IkhomCapri", "ILCATO", "ILCATOplus", "IlonaCollection", "ILTANI", "ImFreshM", "IMAGEFOR", "IMAGO", "Imocean", "Imperial", "ImpressByDress", "IMPRESSLADY", "impressmama", "INCITY", "Indiano", "INDIGIRA", "INDIRASTAR", "IN ES", "Infiniti", "InfinityLingerie", "InNaconcept", "Innamore", "InnOla", "Insania", "IPKEN", "IQdress", "IraKaniukova", "IRBIZZ", "Iren", "IrenaRichi", "IrinaStyle", "IrinaVladi", "Irioli", "IrisvArnim", "IrisRose", "IrmaDress", "IrmaDressy", "IsabeldePedro", "IsabelGarcia", "IsabellaOliver", "IssaPlus", "ISSIbravissimo", "iSwag", "ISYWisewyouwear", "ITONA", "IUKONA", "IvaMosso", "IVERA", "ivvi", "J JMOATTI", "JKbrand", "JackWolfskin", "Jacket", "JACKIESMART", "JACKLIN", "JadoneFashion", "JAM", "JamesPikalov", "JanBidi", "JanSteen", "Janoff", "JasmineStory", "JATRAW", "JeanMarcPhilippe", "Jeanswest", "Jeffa", "JellyKelly", "Jenks", "Jennyfer", "JENOVIYA", "JeSla", "Jessica", "jet joy", "JETTEJOOP", "JETTY", "Jetty plus", "JeuPoitrine", "JimmyKey", "JJWear", "JN", "JODEEN", "Joleen", "Jolifashn", "JOTEX", "JoyceandGirls", "Joymiss", "J Splash", "JTI", "Ju Di", "JuicyCouture", "Juja_design", "JuliePetite", "Juliet", "JULIETROSES", "Julvern", "JUNAROSE", "Juno", "JusdOrange", "JUSCO", "JustBeauty", "JustCavalli", "JustValeri", "KAleksandrova", "Kabelle", "KAFTAN", "KAIMA", "KalinaLook", "KALINKA", "Kama", "KAmoda", "Kaporal", "Kaprize", "KARIONSHOP", "Karree", "KATABINSKA", "KaterinaBleska TamaraSavin", "KaterinaMalina", "KA TI", "Katomi", "KATTANA", "KatyaErokhina", "KatyaKatya", "KAYA", "Kayros", "KeiKei", "KELME", "KEYFASHION", "KG", "Kharitonova", "KIDONLY", "KikiRiki", "Kikiriki", "Killah", "Kingmarin", "KiraPlastinina", "KiS", "KISLIS", "KIWE", "KLASSMAMA", "KLERY", "Klimini", "Kling", "Klodelle", "Knitman", "Komilfo", "KomsomolkaZoe", "Koricohit", "KORINKA", "KOSTRIV CO", "KotisCouture", "KOTON", "KOTS", "KOTTI", "KR", "KRAPIVA", "KrasivO", "KrisLine", "KrisLis", "KrisMajor", "Krismarin", "KRISNA", "Kristina", "KristinaTikhonova", "KSANDRA", "KseniaGospodinova", "KseniaKnyazeva", "KSIKSI", "KTmarka", "KUKLA", "KVINTO", "Kyara", "KYMA", "L L", "LAS", "LEBRAND", "LMSShop", "LStyliya", "LFT", "LABELLE", "LaBelleFemme", "LaBiali", "LaBoheme", "LaChere", "LACITTA", "LaFleuriss", "laJULYET", "LaLuna", "Lamiaperla", "laNIKA", "LaPastel", "LaPlus", "LaRedoute", "LAREINAstyle", "LaReineBlanche", "Larouge", "laselva", "LaViaEstelar", "Lavidarica", "LABFASHION", "LaBellaVita", "LACCOM", "Lacomo", "Lacoste", "Lacy", "LADO", "LadyDi", "LadySharm", "LadySharmClassic", "LadyFreeStyle", "Laete", "LafLafemme", "LaFabricante", "LAFEI NIER", "Laffinely", "Lakbi", "LAKRY", "Lakshmi", "LALIS", "Lamiavita", "LAmour", "Lamugi fashion", "Lamuro", "LamuroBusinessLady", "LanSARO", "LanaAlman", "LANATSUBI", "LANAMORADA", "Laniakea", "Lanicka", "LARRO", "LASCANA", "Lasty", "LATELIER", "LauraBettini", "LauraScott", "LAURASTRAMBI", "Lautus", "LavanaFashion", "Lavand", "LaVela", "Lavelis", "LAVIRA", "La vissa", "LAVLAN", "lawiggi", "Laydies", "L design", "LEFATE", "LEMONIQUE", "LeTempsdesCerises", "LeaVinci", "LEADER", "Leda", "LEDAron", "LEDARON", "LEDI", "LEE", "LeeAnnacollection", "LegendStyle", "Leidiro", "LELEYA", "LeliSposa", "Lelio", "LenaBasco", "LeoGuy", "LeoPride", "LeonCotardie", "Leorgofman", "Leotex", "LERROS", "Leshar", "LesnikovaDesign", "LeSsiSmORE", "Lette", "Letto", "Levall", "Levis", "Leya", "Lezzarine", "LFC", "Libellulas", "Liberty", "LIDEKO", "LiebeFrau", "LifaMosso", "LIFETIME", "LIGIO", "LIGVIANNI", "LIKA", "LikaDress", "Likadis", "Likeit", "Like swomen", "LikModa", "LILAROSE", "LilaVioletta", "Lilove", "LilyLondon", "Limar", "LIMARTI", "LIME", "Limonti", "Lina", "Lindissima", "Linea", "LineaArgenta", "LINEL", "Linemax Group", "LingaDore", "LINORUSSO", "Linse", "LIORA", "LipinskayaBrand", "Lipsy", "LisDesVallees", "LisaBoho", "LisaCampione", "Lisaasil", "LisaWeta", "LISCA", "Liss Liss", "LISSA", "LittleSecret", "LIUJO", "LivaFashionIndustry", "Livaa", "LivCoCorsettiFashion", "LIVE", "LiveForever", "LizaFashion", "LizaVantaggi", "LizaVolkova", "Lkurbandress", "LMDesign", "LNFamily", "LO", "Lobanova", "LOCA", "LOFT_", "LOFTY", "LOIZAbyPatriziaPepe", "LolaJumpper", "Lo Lo", "LONCQ", "London", "LondonTimes", "Look", "LookRussian", "LOOK VOICE", "Looklikecat", "LOONA", "LORAGRIG", "LORANI", "Lorentino", "LORICCI", "LottaGardling", "LOUAN", "Louitex", "LOVA", "LOVECODE", "Loveme", "LoveMoschino", "LoveMyBody", "LOVEREPUBLIC", "LoveStyle", "LoveVita", "LOVE LIGHT", "LoveWait", "Lovebites", "LOVELYOLGEN", "LOVEmily", "LoversinFashion", "LOVERTIN", "lovetexstore", "Lowry", "LTDESIGN", "LTBJeans", "LUAL", "LuAnn", "LuciaMilano", "Lucidoro", "LuckyMove", "LUDMILA", "LUDMILALABKOVA", "Lufana", "Lufashion", "Luhta", "LuietElle", "LUIGIFERRO", "LUISON", "LUMENARS", "LUNAbyDianaLatariya", "LUNEV", "Lusen", "Lusia", "LUSIO", "Lussotico", "Luxury", "LuxuryPlus", "LVSlinea", "LYARGO", "Lynne", "LyubovMalysheva", "M JStyle", "MDjus", "MG", "mim", "MRena", "M DEPOMPADUR", "MAOriginal", "Maaji", "Madam", "Madech", "Madeleine", "MaDii", "Madlen", "MADMILK", "Mado", "MAFUERTA", "MAGJeans", "MAGDA", "MAGICPEOPLE", "MagicStyle", "Magnet", "Magnetiq", "Magnolica", "Magwear", "MAIRONI", "Maisondela Robe", "Maisonespin", "Major Fabric", "Makadamia", "MakeMe", "Malena", "MALI", "MALIYA", "MALKOVICH", "MALLINARA", "Malu", "MamaLicious", "Mamatayoe", "Mamita", "Mammi", "MammySize", "Mams", "Mana", "Mandarin", "Mango", "MANIALE", "ManiFashion", "MANIFEST", "ManilaGrace", "Mankato", "Mantigomo", "MARBI", "MarcO Polo", "MarcVeroMAXXI", "Marc Andre", "MARCH", "MarchelloMarchellini", "MarcoBonne", "Marelina", "MARFA MADONNA", "MargitBrandt", "MARGO", "MariDesignLab", "MARIVERA", "Maria", "MariaDagmar", "MariaDePiero", "MariaGolubeva", "MariaGraziaSeveri", "MariaRybalchenko", "MariaVelada", "MariagraziaPanizzi", "MariamAeva", "Mariashi", "MARICHUELL", "MarieClaire", "MARIETHERO", "MariellaRosati", "MarieM", "MarieMVP", "MariKo", "MARIMAY", "MARINAGRI", "MarinaKalashnikova", "Marina", "MarinaSStyle", "MarinoMilano", "MARIONS", "Mariratta", "Marissimo", "MarkFormelle", "MARKA", "Marlen", "MARRIOLLI", "MARRUSHKA", "MarSe", "MARSOFINA", "MartaBrizhan", "Marterina", "MARUSЯ", "MaryGri", "MARYMEA", "mary_dresses", "Maryrosa", "MaryTes", "MashaMart", "MASIMA", "MAST", "MASTERITSANEWCLASSIC", "MATfashion", "MatFashion", "Matur", "MAURINI", "MAVI", "Max Style", "Maxim", "MAXLINE", "MAXZalisky", "Mayclothes", "MAYAMODA", "mayomay", "MAYSKAYAROZA", "MAZAL", "MdM", "MeLady", "MedeaMaris", "MediS", "MeiLLer", "MEKKOLETO", "MELADO", "MELANA", "MELANIE", "MELANY", "MELLOW", "MERADA", "MERCEDES BENZ", "Merlis", "MerryPerry", "MERSADA", "MET", "MEXX", "MF", "MiaCara", "MiaSofia", "MIAAMO", "MIA AMORE", "MIA MELLA", "Mia Mia", "Mianotte", "Miata", "MICHA", "MichaelKors", "MICHELLEWINDHEUSER", "Migura", "MilaBella", "MilaBezgerts", "MILAMOREL", "MilanaJanne", "MilanaStyle", "MILANIAstyle", "MILANIKA", "MILANIKO", "MILANOITALY", "Milavitsa", "MiLi", "MilkyMama", "Milliner", "MILLION", "MILOMOOR", "MILORI", "Milton", "MIMILARUE", "MINAMA", "Minaku", "Minimum", "Minze", "MirellaSole", "MIRNAЯKONTORA", "MIRONI", "MirrorStore", "Miss Missis", "MISSGABBY", "MissLili", "MissLora", "MissMoi", "missmoneymoney", "MissSixty", "MissDiva", "MissisXXL", "MissMatisse", "MISSMEXX", "MistyCape", "MISUTERI", "MixMode", "MIZA", "Moa", "MOANNA", "Modadilusso", "MODALUXE", "ModaGrata", "Modaleto", "ModaMania", "MODAMAX", "Modellini", "Modellos", "Modern", "modify", "Modis", "Modiva", "Modnoru", "Modstrom", "MODUS", "Mojo", "MOKI", "MOKKOITALY", "MOLITO", "Moliza", "Moltini", "Momkins", "MOMWEAR", "MONBOUQUET", "MONCHERI", "MONPLAISIR", "MONASTYLEFASHION DESIGN", "MONAMISE", "MoNaModNewLook", "MONDIGO", "MONICA", "Monlaydia", "MONOcollection", "MONOROOM", "Monret", "MONTE", "MONTEBELLUNA", "MontiParioli", "MONTI FARR", "Monton", "Monza", "Moodo", "MoonRiver", "MORAL", "MOREDIGELSO", "Morgan", "MORU", "MOSCHINO", "Moscovite", "Mosini", "MOTH", "Motivi", "MOTYLEVA", "Mousa", "MOZART", "MOZZITO", "MR", "MSforyou", "MSLS", "MTY", "Mubliz", "MultiMoskva", "MURLAMOUR", "MY", "MyFashionHouse", "MyTwins", "MyRoma", "Mystic", "My Sweet Skirt", "NbyGlab", "NABclothes", "NAZ", "NMAShine", "NOA", "Nadexforwomen", "NADIAARMAN", "NadiN", "NADO", "NAGOTEX", "NAKAD", "NANSO", "nasha", "NastyaSergeevabyMayBe", "NatMax", "NataNew", "NataliSilhouette", "NataliaVolk", "NATALIAZUBTSOVA", "Natalya Tretyakova", "Natastyle", "NathalieVleeschouwer", "Natori", "Natura", "Naturel", "Naturemio", "NAVY", "N collection", "NEFERTARIDRESS", "Nelly Co", "Neohit", "NEVAPLUSRU", "Nevis", "NewJ", "NewLook", "NEWJ", "NewSchool", "NicClub", "Nicolecollection", "NICOLETTA", "Nidd Ange", "Nife", "NikaDress", "NikaFashion", "NikaLove", "Nike", "NikiBiki", "NikolayKiseliov", "NikolayKiseljov", "NIL", "NinaRiga", "NINAROSSI", "NinavonC", "Ninel", "NINELTextile", "NKStyle", "NOBILI", "NocheMio", "Noele", "NOIR", "Nolita", "Nomes", "Noppies", "Norm", "Normann", "NotTheSame", "NothingbutLove", "Numph", "NuovaVita", "Nuvola", "ODeMai", "OJen", "OSheb", "OBJECT", "Ocean", "ODALIA", "Odetta", "odevaiS", "Odis", "ODORINI", "ODORO", "ODRI", "OfWhite", "OFERA", "Ofslide", "OKS", "OKSby Oksana Demchenko", "Oksana Zigert", "OL DI", "Olavi", "OLBE", "OleGra", "OLENNY", "OlesaChugunova", "OlgaPeltek", "OlgaSkazkina", "OlgaVishop", "Olian", "OLIVEGREY", "OliviaHopsbyCristinaGavioli", "Oliya", "Ollsy", "Ollure", "OLSI", "Oltre", "OlyaStoff", "OMGA", "Onalima", "onatej", "One Green Elephant", "OneImage", "Onemorewave", "ONEPLANET", "OneplusOne", "ONEQUEEN", "ONeill", "ONLY", "OnlyStylishGirlsbyPatriziaPepe", "ONLYWAY", "ONLYTWOME", "Oodji", "open style", "OPIUM", "ORHIDEA", "Orion", "OrionLondon", "OROBLU", "ORTYS", "OStin", "Otli", "OTOLI", "Ouarida", "OUTFITTERSNATION", "OVALOVA", "OV DRESS", "OVS", "OWLS", "OXO", "OZKANUNDERWEAR", "ozozylo", "ozozylolight", "ozozyloline", "OZZI", "Paccia", "PALLARI", "PALVINI", "Palvira", "Pamela", "Panda", "PaniMilovska", "PANTAMO", "PAOLAMORENA", "Paola Rossi", "Paparazzi Fashion", "PARADOX", "Paragon", "Paramour", "Paris", "PARISTAN", "PARKhande", "PAROLEbyVictoriaAndreyanova", "Pastel", "Pastilla", "PATRICIACHARME", "PatriziaDini", "Pattern", "Pavesa", "PAVLI", "Pavlotti", "PAVLUKHINA", "PAVO", "PECHEMONNAIE", "Pelagueya", "PELICAN", "PENYEMOOD", "PEONY", "People", "PEPEJEANSLONDON", "PEPEN", "Peperuna", "Pepita", "Perfect", "PERFECTJ", "Perfect_ma_", "Personage", "PERSPECTIVE", "Peserico", "PeterHahn", "PetitPas", "PetRoMaks", "Petti Dress", "PETTLIcollection", "Pezzo", "PF", "PiazzaSempione", "Piccaninnyclub", "Picoletto", "PIKANTO", "PinkWoman", "PINKO", "PiolaStudio", "Pique", "PiRina", "PIZHAMASHOP", "PlayFashion", "Plnclub", "PLUMS", "PlusModa", "poPogode", "PoisonPinky", "PolaMondibyMerla", "polesie", "Pompa", "PORFIRA", "Poustovit", "POZA", "Prema", "Prestige", "PRESTIGESTYLE", "PrettyWoman", "PrimaLinea", "PrimebyLilyaRafikova", "PRIMEROVA", "Princessedemonaco", "PRIO", "PRIZABILE", "PRIZZARO", "Profit", "PROFITOAVANTAGE", "Progress", "ProudMom", "PUMA", "PunkQueen", "Pura", "Quattro", "QuattroStili", "QueenMum", "Queens", "QUEENSYNDROME", "QUIOSQUE", "RO", "Rabe", "RADOST", "RAMANTI", "Ramina", "Ramires", "RAQUEL", "RARE", "Razmerika", "REBECCATATTI", "REDTULIP", "Reds", "Reebok", "Reforma Kids", "REGATTA", "REGINADIPICCO", "ReginaStyle", "Reina", "RELAXMODE", "Religion", "Relish", "Remix", "ReneDerhy", "Replay", "Reserved", "Reshka", "RiClo", "rimari", "RibbonDesign", "RicaMare", "RicaMare", "Richardi", "Ricoco", "RiCPlus", "Rihanna", "RIJJINI", "Rimma Allyamova", "Rinascimento", "RINGELLA", "RISE", "Risha", "RitaKoss", "Ritini", "RIVA", "RIVADU", "RiverWoods", "ROBERTABIAGI", "RobertaBiagiSrl", "ROBERTOBIAGI", "RobertoJolini", "Rocawear", "ROCKME", "Rodionov", "ROLYPOLY", "ROMANA", "ROMAS", "Romashka", "Romeo JulietCouture", "Romgil", "ROSABLANCA", "RosaBlanco", "RosaShock", "Rosabella", "Rosanna", "RoseNoir", "Rosee", "RoserSamonPromise", "Rossini", "ROSSO STYLE", "ROXY", "RoyalElegance", "ROYALGLAMOUR", "ROYALTEXTIL", "RoyalWay", "RRbyReznikRimma", "RUMOUR", "Rumeour", "Runika", "RusLana", "RUSSICOUTURE", "RUXARA", "Ryazhenka", "RYLKOFASHION", "S E", "S SbySZotova", "SOLIVER", "S Cool", "SR", "Sabellino", "Sabotage", "SaheraRahmani", "SAINTFUNNY", "Sakton", "SALHAM", "SaliHovadesign", "salko", "Salsa", "Salvi", "SAMERHONEY", "Samirini", "SAMO", "SAMOS", "Sandwich", "SangerStyle", "Sansa", "Santi", "SAOPAULO", "SAPA", "SARAZERIN", "Sarafan", "Sargol", "SARTORIDODICI", "SashaRozhdestvenskaya", "SASHYOU", "Satin", "SAVAMARI", "SAVAGE", "Say", "SAYMYNAME", "Scandica", "Scool", "ScorpionBay", "SDRESS", "SEAM", "SEANNA", "SELA", "SELECTED", "SELENA", "Selenik", "SelfMade", "Sempre", "Senta", "Serenada", "Serge", "SergioBellini", "SERGIOTATTI", "SERGIOVALENSA", "SETTYs", "SevenDevils", "Seventeen", "SeventilMidnight", "Seventy", "SeveriDarling", "SEVIM", "SEVONA", "Sewel", "SezonStylе", "SEZONI", "s family", "SHADEknitwear", "SHALLE", "SHARTREZ", "Sharvell", "SHEGIDA", "Shelter", "Shened", "SHENGTANGKUYI", "SHESSO", "Shokolat", "shovSvaro", "SI GI", "SiempreesViernes", "SigmaStyle", "SIGNATURE", "SILKME", "SilverFish", "Silverflower", "SILVERHANDS", "Silver String", "SILVIANHEACH", "SimaniCollection", "SIMPLY", "SINNERsBONES", "SISIBELLA", "Sisley", "SISTERSPOINT", "SISTES", "Sitlly", "SKANDAЛ", "SK House", "Skiny", "SkyLake", "SLFashion", "Small Tall", "Smash", "SmashedLemon", "SNN collection", "SNOBS", "Soeasy", "SOFFIHOME", "SofiStrokatto", "SOFI ANA", "Sofia", "SOFIANA", "SoftLight", "SOFTSECRET", "SOL", "SOLH", "SOLObyendea", "SoloFarfalle", "Solo_TU", "SoloU", "SONALECREATION", "Sonett", "SonyaScandal", "Soofre", "Soulmate", "SOUTHERNCOTTON", "SPARADA", "Sparkle", "Spicery", "Splensilk", "SportVision", "Springfield", "SSENIORE", "STseventeen", "StEmile", "StRadost", "Start", "Startale", "Startalehome", "Stefanel", "Stefko", "STEINBERG", "StellaGuardino", "Stets", "Stilla", "Stillini", "Stilnyashka", "Stimage", "STIMMA", "STRILS", "Studio", "StudioSeven", "StudioSeven", "Stylenational", "Styleyou", "StypeAtelie", "SUARA", "SUCCESS", "SUGARLIFE", "SultannaFrantsuzova", "Sun Art", "SUN MOON", "SunRise", "SuperDrySport Snow", "SUXE", "SUZDALSHOP", "SVESTA", "SveTekst", "SVETLANOVA", "SVline", "SWANK", "SweetMe", "Sweetissima", "SWKUB", "Symphony", "T B", "T BBase", "T M", "tatu", "TACHIQUE", "TAILORCHE", "TAKITANIA", "TALES", "TALIA", "TALLENZA", "TallWomen", "TallyWeijl", "TanaHomeCollection", "Tantino", "TANTRA", "TanyaPakhomova", "TashaMartens", "TATI", "TATUUM", "Taubert", "Tayajeans", "Tchibo", "TDKalita", "TDVALERIYA", "TDVALERIYAHOME", "TeAmo", "TedBaker", "Tenerezza", "TERATAI", "TERRA", "TESORObyVictoriaKlebanova", "Tesoro", "TF", "TheCave", "THEHILLS", "TheMom", "TheDistinctive", "THEMACCA", "THEONEBYSVETLANAERMAK", "TifTiffy", "Tigtexru", "tiho", "TIMEOUT", "Timezone", "TipTop", "Titaniathelabel", "tobebride", "TODAYS", "TokuTino", "TOMFARR", "TomFarrVintage", "TOMTAILOR", "TommyHilfiger", "TOMMYJEANS", "TOONTEX", "TopInStyle", "TopSecret", "TopStudio", "TOPSANDTOPS", "Toryz", "TOTALLOOK", "Totti", "TrafficPeople", "TrendyTummy", "TrendyAngel", "TresorCouterier", "Trespass", "TREVI", "TRGNewideasforlife", "TriKoshki", "Trikozza", "Triumph", "TrixiSchober", "Troll", "TrueRed", "Trussardi", "t sod", "Tsurpal", "Tutachi", "TUTTAMAMA", "TuttoBene", "Tuwe", "TUZUN", "TUZZI", "TUZZINERO", "Tverknit", "TwentyOne", "TwentyTwo", "TWIN", "TwoFace", "Tworivers", "TZETZE", "USPoloAssn", "UDress", "ULTIS", "UltraModa", "UMM", "Ummami", "UNDOEXCLUSIVE", "UNIC", "UNIOSTAR", "UnitedColorsofBenetton", "UNNA", "UNONADART", "UNQ", "UONA", "Ura", "URAURBAN", "URBANDRESS", "URBANGARAGE", "UrbanGrass", "UrbanTiger", "URBANO", "UTENOS", "V D", "V Florence", "V V", "V X", "VIPA", "VAVAVOOM", "VadimMerlis", "Vaide", "Valentina", "Valeri", "ValeriaLux", "Valkiria", "Valore", "Valova", "Valtusi", "ValZa", "VAMPA", "VAN DOS", "Vanessa", "VanillaBay", "VANS", "VARG", "VAY", "VC K", "Veil", "VELOCITY", "VelVet", "Venera", "VeneraForema", "VeneraByTerentieva", "VENUSITA", "veramoni", "VeraMont", "VeraNicco", "VERANOVA", "VERDA", "VERDEREVSKAYA", "Verezo", "VERNASEBE", "VEROMODA", "Veronicaiko", "VeronikaStyle", "VeroWear", "Versaly", "VESIVIO", "Vesta", "Vestir", "Vestiri", "VEZZARO", "Vikante", "ViaLattea", "ViaRichi", "Viaggio", "Viaville", "VICOLO", "VictoriadeSoie", "VictoriaFilippova", "VictoriaKuksina", "VictoriaLoks", "VICTORIAVEISBRUT", "VienettaSecret", "VIKImagination", "VIKARA", "Vika Smolyanitskaya", "Vikki Nikkiforwomen", "Viksena", "Vil_wear", "Vila", "VILAJOY", "Vilana", "VILATTE", "VILLAGI", "VIOBELLA", "VioletabyMango", "Violett", "VIPSTYLE", "VIPART", "VipDressCode", "VirgiStyle", "Vis a vis", "VISERDI", "Vision Fashion Store", "VISSON", "Vita Brava", "VITASTRETTA", "Vito", "Vitto Riyan fashion", "Vittoria Felice", "Vittoria Vicci", "VivalaDonna", "Vivalavita", "VIVATEX", "Vivaldi", "VIVAMAMA", "Viviarte Studio", "VivienneMare", "VIVO", "Vix Vox", "VIZANTI", "VLADI Collection", "VLADOR", "VLTVIOLETTA", "VLАDI Collection", "VOI JEANS", "Voielle", "Volcom", "Volna", "VOLPATO", "VONDUTCH", "Vosmae", "Wfashion", "W B", "WSharvel", "WATCH ME MOSCOW", "week by week", "Well dress", "Wenz", "Weraberto", "Whimsy", "W HITEbyWTFC", "White City", "WHITECUFF", "WHITNEY", "WHOLEFOLKS", "Wiento", "Wilymoose", "WIN WOOL", "Winzor", "Wisdom", "Wisell", "Wiya", "WOLFORD", "Women Secret", "Woolhouse", "Woolys", "WORLD FACES", "Wow Couture", "WoW", "Wrangler", "WS", "Xarizmas", "Xenia", "XeniaDukova", "XINT", "xLady", "XZotic", "YMMYMAMMY", "YaLosAngeles", "YadvigaLocika", "Yarmina", "YAROSLAVNA", "YAS", "YBAPOBA", "Yerse", "YES YULINESS", "YFS Your Fashion Style", "YKSSTУDIO", "YLIN P", "YLLUZZORE", "YOU LOOK", "You Look Studio", "YOU ME", "Yudashkin Jeans", "Yuka", "Yukostyle", "Yulia Dushina", "YULIASWAY", "YuliyaShehodanova", "YurMa", "YUVITA", "ZOXA", "ZYC", "ZAF", "ZAFTO", "ZAIN", "Zaira Gatagazheva", "Zakiyyah", "ZARGA", "ZARINA", "ZARKA", "ZARUS", "ZASPORT", "ZATTANI", "ZAYKINS", "zdress", "Zefir", "ZENDRA", "ZERKALA", "ZERO", "ZEZONI", "ZHAKKO", "ZHU", "Zia", "ZIP ART", "ZIQ YONI", "ZLATON I", "Z MAX", "ZOHEN", "ZOI", "Zola", "ZoyaLets", "ZUELEMENTS", "ZVEZDA", "Авантюра", "Агапэ", "Адель", "АдинаТекс", "Аленушкатрикотаж", "Алина Текс", "АЛТЕКС", "Алтекс", "Амадэль", "АМАЛИЯ", "Амама Я несу счастье", "Анастасия Надыктова", "Ани Сима", "Анна Голицына", "анна фортуна", "АннаЧапман", "АНО", "Антали", "Апрель", "АриадНА", "Армия России", "Арт Деко", "Артесса", "Артишок", "Ачоса", "Багира", "Багряница", "Барыня", "БАТНИК", "Бая На", "Белан текстиль", "Белова Ирина Николаевна ИП", "Битис", "Бурси Бурвин", "Валкотекс", "ВАРМИ", "Ваша Шляпка", "Вдвоем", "ВЕББИС", "ВЕДУНЬЯ", "Ведунья", "ВЕРЕСК", "Веста", "Веста", "Весталия", "Вестетика", "ВикторФедирко", "ВиоТексПартнер", "Виреле", "ВИТА", "Вишня", "ВолгаТекс", "Волжанка", "Волтри", "Вяснянка", "Гамма", "ГАНГ", "Гардеробчик", "Гизарт", "ГлорияТрикотаж", "Голд Стайл", "Город Горький", "ГОРОДСКОЕ ПЛАТЬЕ", "ГОРОДСКОЕ ПЛАТЬЕ ФОЛК", "Грация Стиля", "Далория", "Данаида", "Данилычева", "ДАрина", "Дарья", "Детский Бум", "Доммоды Lili", "Домтекстиль", "ДушеГрея", "ЕВРОСТИЛЬ", "ЕЖЕВИКА", "ЕленаДик", "ЕленаПрекрасная", "ЕЛЕНА ДИЗАЙН", "Елизавета", "Есения", "ЖЕЛИМА", "Зар А стиль", "Звезда для тебя", "Зимна квiтка", "Золотое Лекало", "Золото еруно", "ЗОЛОТО ЕРУНО", "ИВ ИВАНУШКА", "Иваново Глав Трикотаж", "Ивассорти", "ИВ МОДЕЛЬ", "Ив Рос Текстиль", "Идеальнаялиния", "Интикома", "ИП Абгарян ЛС", "ИП Комарова СН", "ИП Кузнецов ДВ", "ИП Латышева ИЮ", "ИП Манвелян ГВ", "ИП Панков НГ", "ИП Савицкая ИВ", "ИП Савосина ТВ", "ИП ТарнавскийСИ", "ИП Уткин МВ", "ИП Яровицына НВ", "Ирида", "Ирэнстиль", "ИскринаСтиль", "Иссти", "Как Мечта", "КАЛIНКА", "Калинка", "Катя Катюша", "КВК", "Келен", "Классическаямода", "Клиона", "Кокетка", "Концерн Курск трикотаж пром", "КОСТЮМЕР", "КОТМАРКОТ", "Краса", "Красавушка", "Красная Ветка", "Красная Заря", "Криволапова", "Кристина Русь", "Кузнецова", "Кузьмин Анатолий Павлович ИП", "Культплатья BRACEGIRDLE", "Кумар Коллекшн", "Купалинка", "Купчихи", "Лагуна", "ЛАДОШКИ", "Лала Стайл", "ЛАНА", "Ланкома", "ЛаТэ", "Лауме Лайн", "Левлада", "Леди Агата", "Лена Ра", "Лента Стиль", "ЛЕО", "ЛитанияMIR", "Лиф тайлер", "Лори", "ЛОТО Стрикотаж", "ЛУИЗА", "Льняная горница", "Люби Текс", "Людмила", "МадамРимма", "МадамРита", "МадаМТ", "МАДИС", "МАК", "Макс", "Макс Экстрим", "Малина", "Мама Мила", "Мама Бэль", "МАМАРАДА", "Мамуля красотуля", "Мамы в моде", "Мануфактурная лавка", "Мараплюс", "Марго", "Мари лайн", "Марина", "МариЧи", "МаркаКотовых", "Маркиза", "МарЛен", "МаТильда", "Махаон", "МЕДЕЛЛИ", "Мелисса", "Мелиссена", "Мечты Данаи", "Милада", "Мира Сезар", "Мираслава", "Мирося", "МИРЯНКА", "Модный стиль", "Мотив", "Мотылева", "МТГ", "Мультитекс", "Мы команда", "На Всегда", "Надя Хохлова", "Название наше", "Налина", "Народная марка", "Настаси", "Натали", "НАТАЛИКА", "Наталья Новикова", "НАШ СЕЗОН", "НАШЕ", "Неженка", "НЕЖКА", "Незнакомка", "Нессея", "Нефертити", "НИКО ТЕКСТИЛЬ", "НИКОЛЬ МОРЕФ", "НИКОЛЬ СТИЛЬ", "НиРо", "Новое время", "Новое кимоно", "Ням Ням", "ОДДИС", "ОДДИС", "ОДЕВАЕМ ПУЗИКИ", "Одевайся Легко", "Одевайте", "Одежда Классик", "ОДЕКС СТИЛЬ", "ОДНА ВТОРАЯ", "Оланж Ассорти", "ОЛМИС", "Ольга", "ОЛЬКО", "ОльТа", "ООО Анюта", "ООО Весна", "ООО Дана Текс", "ОООСпектр", "ОООСтиль ЮНИТЭ", "ООО Трикотаж МИЛАНА", "Орнелла", "Париж", "ПАРТИЯМОДЫ", "ПарусТекс", "Персона", "Петербургскийстиль", "ПетербургскийШвейныйДом", "ПКФУспех", "Полина", "Полноесчастье", "Премьера", "ПСЖ", "Птица", "Радо Вест", "Райский Лотос", "РОССИЙСКИЙ ТРИКОТАЖ", "Россиянка", "Русмар", "Русская Коллекция", "РУССКИЙ СЕЗОН", "Руся", "Сиголочки", "Саба", "Самое", "Свiтанак", "Светлана", "Северная Лагуна", "Селтекс", "Серафима", "Синель", "Сиринга", "Снежинка", "Снобс", "СОНЯ МАРМЕЛАДОВА", "Софителле", "Спаленка", "СТиКО", "Стилвиль", "Стиль Fashion Lux", "Сударыня", "Сундукова", "Талори", "Тамбовчанка", "Танита", "ТатаАкварель", "ТатьянаСулимина", "ТВОЕ", "ТВОЙИМИДЖ", "Твойстиль", "ТДВалерия", "ТекстильХаус", "ТЕО", "Тефия", "ТОММ", "Тома", "ТомилочкаМодаТМ", "ТОП", "Точка", "ТРАДИЦИИТРИКОТАЖА", "ТриМаруськи", "Трика", "Трикотажслюбовью", "Трикотажклуб", "Трикотажница", "Трикотажноепредприятие МАРИЯ", "Трикотекс стиль", "ТРИ ТРИКОТАЖ", "ТРОФIMOFF", "Тульскийтрикотаж", "Тюрина Светлана Александровна", "Фedora", "Фасхутдинова", "Фонтема", "ФОРЕСКА", "Форма", "ФЭСТ", "Хорошава", "ХОУМСТАЙЛ", "Хоум Стайл", "Царевна", "Царицын Дом", "ЦЭХ", "Шарлиз", "Швейное производство КОНСУЛ", "Швея", "Шетрик", "ШИК", "ШИК", "ЭЛЕГАНТЛЕДИ", "ЭЛИАНА", "Элиза", "ЭНСО", "Этноарт", "ЮВ КА", "Яблонька", "ЯН", "Ярославская Мануфактура" ]

    
    var colors = ["biege", "white", "blue", "yellow", "green", "brown", "red", "orange", "pink", "gray", "darkblue", "violet", "black"]
    
    enum ColorEnum : Int{
        case biege = 0, white, blue, yellow, green, brown, red, orange, pink, gray, darkblue, violet, black
    }
    
    enum FilterEnum  {
        case size, material, delivery, decorElements, season, clasp, liningMaterial, trouserModel, pocketType, warmer, fitType, sleeveType, neckline, hoodOptions, clothingLength, temperatureСondition,shoeLiningMaterial, shoeSoleMaterial,
        insoleMaterial, skirtModel, skirtLength, jeansModel, jeansFeatures, dressStructuralElements, trouserModelPantsCut
    }
    
    
    
    private var filters: [Int:FilterModel1] = [:]
    private var itemsBySubfilter: [Int: [Item]] = [:]
    private var subfiltersByFilter: [Int:[Int]] = [:]
    private var subFilters: [Int:SubfilterModel1] = [:]
    private var subfiltersByItem: [Int:[Int]] = [:]
    
    
    func getCountsByColor(biege: Int,
                          white: Int,
                          blue: Int,
                          yellow: Int,
                          green: Int,
                          brown: Int,
                          red: Int,
                          orange: Int,
                          pink: Int,
                          gray: Int,
                          darkblue: Int,
                          violet: Int,
                          black: Int) -> [Int:Int]{
        var res: [Int:Int] = [:]
        res[ColorEnum.biege.rawValue] = biege
        res[ColorEnum.white.rawValue] = white
        res[ColorEnum.blue.rawValue] = blue
        res[ColorEnum.yellow.rawValue] = yellow
        res[ColorEnum.green.rawValue] = green
        res[ColorEnum.brown.rawValue] = brown
        res[ColorEnum.red.rawValue] = red
        res[ColorEnum.orange.rawValue] = orange
        res[ColorEnum.pink.rawValue] = pink
        res[ColorEnum.gray.rawValue] = gray
        res[ColorEnum.darkblue.rawValue] = darkblue
        res[ColorEnum.violet.rawValue] = violet
        res[ColorEnum.black.rawValue] = black
        
        return res
    }
    
    func getFirstFilterId() -> Int {
        return 3
    }
    
    
    func uploadCategory(categoryId: Int){
        let rootRef = Database.database().reference()
        let ref = rootRef.child("categories").child("category\(categoryId)")
        ref.setValue(["categoryId": categoryId])
        uploadUIDs(categoryId: categoryId)
    }
    
    func uploadCrossUIDs(){
        uploadCrossUIDss(filterId: DataLoadService.CrossFilterEnum.brands.rawValue)
        uploadCrossUIDss(filterId: DataLoadService.CrossFilterEnum.colors.rawValue)
    }
    
    func uploadCrossUIDss(filterId: Int){
        let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.filters.rawValue, cross: true, filterId: filterId, categoryId: 0, firebaseTemplate: self)
      //  let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.itemsBySubfilter.rawValue, cross: true, filterId: filterId, categoryId: 0, firebaseTemplate: self)
       // let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.subfiltersByItem.rawValue, cross: true, filterId: filterId, categoryId: 0, firebaseTemplate: self)
    }
    
    func uploadUIDs(categoryId: Int){
        let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.filters.rawValue, cross: false, filterId: 0, categoryId: categoryId, firebaseTemplate: self)
        let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.itemsBySubfilter.rawValue, cross: false, filterId: 0, categoryId: categoryId, firebaseTemplate: self)
        let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.subfiltersByItem.rawValue, cross: false, filterId: 0, categoryId: categoryId, firebaseTemplate: self)
        let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.priceByItemId.rawValue, cross: false, filterId: 0, categoryId: categoryId, firebaseTemplate: self)
        let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.prefetch.rawValue, cross: false, filterId: 0, categoryId: categoryId, firebaseTemplate: self)
        let _ = UidModel(uid: UUID().uuidString, type: DataTypeEnum.catalogIds.rawValue, cross: false, filterId: 0, categoryId: categoryId, firebaseTemplate: self)
    }
    
    
    func uploadCrossFilters() {
        let _ = FilterModel1(id: 1, title: "Бренд", categoryId: 0, filterEnum: .section, cross: true, uuid: UUID().uuidString, firebaseTemplate: self)
        let _ = FilterModel1(id: 2, title: "Цвет", categoryId: 0, filterEnum: .select, cross: true, uuid: UUID().uuidString, firebaseTemplate: self)
        uploadCrossUIDs()
    }
    
    func uploadCrossSubFilters() -> (Int, [Int]) {
        var lastSID = 0
        var brandIds: [Int] = []
        
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "бежевый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "белый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "голубой",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "желтый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "зеленый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "коричневый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "красный",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "оранжевый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "розовый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "серый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "синий",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "фиолетовый",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        let _ = SubfilterModel1(id: lastSID, filterId: 2, title: "черный",  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self)
        
        lastSID = 20
        brands.forEach({brand in
            brandIds.append(lastSID)
            let _ = SubfilterModel1(id: lastSID, filterId: 1, title: brand,  categoryId: 0, cross: true, next: &lastSID, firebaseTemplate: self, useSection: true)
        })
        
        return (lastSID, brandIds)
    }
    
    
    func createItemIds(nextItemId: inout Int, totalItems: Int) -> [Int] {
        var itemIds: [Int] = []
        var last = 0
        for i in 0...totalItems-1 {
            itemIds.append(nextItemId + i)
            last = nextItemId + i
        }
        nextItemId = last + 1 + 1 // last + idx 0 + next
        return itemIds
    }
    
    func createItemImage(catergoryId: Int, itemIds: [Int], countsByColor: [Int: Int]) -> [Int:String]{
        var nextId = 0
        var imageByItem: [Int:String] = [:]
        for (colorId, count) in countsByColor {
            guard count > 0 else { continue}
            for i in 0...count-1 {
                let itemId = itemIds[nextId]
                nextId += 1
                let colorName = colors[colorId]
                imageByItem[itemId] = "\(catergoryId)_" + colorName + "_\(i)"
            }
        }
        return imageByItem
    }
    
    func createItemColor(itemIds: [Int], countsByColor: [Int: Int]) -> [Int:Int]{
        var nextId = 0
        var colorByItem: [Int:Int] = [:]
        for (colorId, count) in countsByColor {
            guard count > 0 else { continue}
            for _ in 0...count-1 {
                let itemId = itemIds[nextId]
                nextId += 1
                colorByItem[itemId] = colorId
            }
        }
        return colorByItem 
    }
    
    
    
    func uploadFilters(categoryId: Int, nextFilterId: Int, filters: [FilterEnum] ) -> (Int, [Int:Int], [Int: Int]){
        var lastFID = nextFilterId
        var filterByCode: [Int:Int] = [:]
        var multipleFilter: [Int: Int] = [:]
        
        let _ = FilterModel1(id: lastFID, title: "Цена", categoryId: categoryId, filterEnum: .range, cross: false, uuid: UUID().uuidString, firebaseTemplate: self)
        lastFID += 1
        
        filters.forEach({name in
            switch name {
            case .size:
                let _ = FilterModel1(lastFID, "Размер", categoryId, .select, false, UUID().uuidString, 3, &filterByCode, &lastFID, multiPerItem: 1, multipleFilter: &multipleFilter, firebaseTemplate: self)
                
            case .material:
                let _ = FilterModel1(lastFID, "Состав", categoryId, .select, false, UUID().uuidString, 4, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .delivery:
                let _ = FilterModel1(lastFID, "Срок доставки", categoryId, .select, false, UUID().uuidString, 5, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .decorElements:
                let _ = FilterModel1(lastFID, "Декоративные элементы", categoryId, .select, false, UUID().uuidString, 6, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .season:
                let _ = FilterModel1(lastFID, "Сезон", categoryId, .select, false, UUID().uuidString, 7, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .clasp:
                let _ = FilterModel1(lastFID, "Вид застежки", categoryId, .select, false, UUID().uuidString, 8, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .liningMaterial:
                let _ = FilterModel1(lastFID, "Материал подкладки", categoryId, .select, false, UUID().uuidString, 9, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .trouserModel:
                let _ = FilterModel1(lastFID, "Модель брюк", categoryId, .select, false, UUID().uuidString, 10, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .pocketType:
                let _ = FilterModel1(lastFID, "Тип карманов", categoryId, .select, false, UUID().uuidString, 11, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .warmer:
                let _ = FilterModel1(lastFID, "Утеплитель", categoryId, .select, false, UUID().uuidString, 12, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .fitType:
                let _ = FilterModel1(lastFID, "Тип посадки", categoryId, .select, false, UUID().uuidString, 13, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .sleeveType:
                let _ = FilterModel1(lastFID, "Тип рукава", categoryId, .select, false, UUID().uuidString, 14, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .neckline:
                let _ = FilterModel1(lastFID, "Вырез Горловины", categoryId, .select, false, UUID().uuidString,  15, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .hoodOptions:
                let _ = FilterModel1(lastFID, "Опции Капюшона", categoryId, .select, false, UUID().uuidString, 16, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .clothingLength:
                let _ = FilterModel1(lastFID, "Длина Одежды", categoryId, .select, false, UUID().uuidString, 17, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .temperatureСondition:
                let _ = FilterModel1(lastFID, "Температурный режим", categoryId, .select, false, UUID().uuidString, 18, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .dressStructuralElements:
                let _ = FilterModel1(lastFID, "Конструктивные элементы", categoryId, .select, false, UUID().uuidString, 19, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .shoeLiningMaterial:
                let _ = FilterModel1(lastFID, "Материал подкладки обуви", categoryId, .select, false, UUID().uuidString, 20, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .shoeSoleMaterial:
                let _ = FilterModel1(lastFID, "Материал подошвы обуви", categoryId, .select, false, UUID().uuidString, 21, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .insoleMaterial:
                let _ = FilterModel1(lastFID, "Материал стельки", categoryId, .select, false, UUID().uuidString, 23, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .skirtModel:
                let _ = FilterModel1(lastFID, "Модель Юбки", categoryId, .select, false, UUID().uuidString, 26, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .skirtLength:
                let _ = FilterModel1(lastFID, "Длина Юбки", categoryId, .select, false, UUID().uuidString, 27, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .jeansModel:
                let _ = FilterModel1(lastFID, "Длина Юбки", categoryId, .select, false, UUID().uuidString, 28, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .jeansFeatures:
                let _ = FilterModel1(lastFID, "Джинсы Особенности Модели", categoryId, .select, false, UUID().uuidString, 29, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            case .trouserModelPantsCut:
                 let _ = FilterModel1(lastFID, "Крой", categoryId, .select, false, UUID().uuidString, 30, &filterByCode, &lastFID, multiPerItem: 0, multipleFilter: &multipleFilter, firebaseTemplate: self)
            default: break
            }
        })
        return (lastFID, filterByCode, multipleFilter)
    }
    
    
    
    
    func uploadSubFilters(categoryId: Int, filterByCode: [Int:Int], _subfilterId: Int) -> (Int, [Int: [Int]]) {
    
        var subfiltersByFilter: [Int:[Int]] = [:]
        var lastSID = _subfilterId
        
        for (code, filterId) in filterByCode {
            switch code {
                
            case 3:
                for i in 0...20 {
                    let _ = SubfilterModel1(lastSID, filterId, "\(32 + i)", categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 4:
                let material = ["ангора","ацетат","бамбук","вискоза","кашемир","лен","люрекс","модал","нейлон","полиамид","полиуретан","полиэстер","текстиль","хлопок","хлопок","шелк","шерсть","эластан"]
                for i in 0...material.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, material[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 5:
                let delivery = ["1 день","3 дня","4 дня","5 дней",]
                for i in 0...delivery.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, delivery[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 6:
                let decor = ["аппликация","банты","бахрома","без элементов","бисер","брелок","брошь","бусины","вышивка","драпировка","заклепки","из камня","из серебра","камни","кант","карман","кисточки","кристаллы SWAROVSKI","кристаллы","кружево","кулиска","лента","логотип","люверсы","макраме","меховая оторочка","молния","оборка","пайетки","перфорация","перья","подвеска","помпон","принт","пряжки","пуговицы","резьба","ремешок","рюши","с капюшоном","светоотражающие вставки","сетка","складки","состаренный эффект","стразы","тесьма","тиснение","ушки","цветы","цепочки","шнуровка"]
                for i in 0...decor.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, decor[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 7:
                let season = ["демисезон","зима","круглогодичный","лето"]
                for i in 0...season.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, season[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 8:
                let clasp = ["без застежки","завязки","зажим","замок с ключом","карабин","клапан","клевант","кнопки","крючки","липучка","магнитная кнопка","молния","поворотный замок","пряжка","пуговицы","резинка","супатная","шнуровка","эластичная вставка"]
                for i in 0...clasp.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, clasp[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 9:
                let liningMaterial = ["акрил","ацетат","без подкладки","вискоза","ворсин","евромех","искусственная замша","искусственный материал","искусственный мех","кашемир","купро","мех","модал","натуральный мех","полиамид","поливискоза","полипропилен","полиуретан","полиэстер","полиэфир","синтетическая кожа","текстиль","флис","хлопок","шелк","шерсть","шерстянной мех","эластан"]
                for i in 0...liningMaterial.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, liningMaterial[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 10:
                let trouserModel = ["багги","бананы","без брюк","галифе","джоггеры","зауженные","карго","классические","клеш","облегающие","прямые","укороченные","чинос","широкие"]
                for i in 0...trouserModel.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, trouserModel[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 11:
                let pocketType = ["без карманов","в шве","кенгуру","накладные","прорезные","с отрезным бочком"]
                for i in 0...pocketType.count-1 {
                    let _ = SubfilterModel1( lastSID, filterId, pocketType[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 12:
                let warmer = ["бамбуковое волокно","без утепления","ватин","изософт","искусственный мех","махра","микроволокно","натуральный мех","начес","нейлон","перо","полиамид","полиэстер","полиэфир","пух","сиберия","синтепон","термофин","тинсулейт","флис","хлопок","шерсть"]
                for i in 0...warmer.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, warmer[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 13:
                let fitType = ["высокая","низкая","средняя"]
                for i in 0...fitType.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, fitType[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 14:
                let sleeveType = ["3/4","без рукавов","длинные", "короткие"]
                for i in 0...sleeveType.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, sleeveType[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 15:
                let neckline = ["V-образный","американка","ассиметричный","бандо","бретель-петля","водопад","воротник-стойка","гольф","запах","капелька","каре","кармен","лодочка","на бретельках","на одно плечо","округлый","отложный воротничок","фигурный","хомут","шалька"]
                for i in 0...neckline.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, neckline[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 16:
                let hoodOptions = ["без капюшона","несъемный капюшон","съемный капюшон"]
                for i in 0...hoodOptions.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, hoodOptions[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 17:
                let clothingLength = ["длина до талии","до бедра","до колена","ниже колена"]
                for i in 0...clothingLength.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, clothingLength[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 18:
                let temperatureСondition = ["от +18 до +24","от 0 до -15","от +10 до +20", "от +10 до -10", "от +10 до -5", "от +5 до +15", "от +5 до -10", "от +5 до -30", "от 0 до +10", "от 0 до +20", "от +0 до +5", "от 0 до -10", "от 0 до -20", "от 0 до -30", "от 0 до -35", "от -10 до -20", "от -10 до -25", "от -5 до +5", "от -5 до -10", "от -5 до -15"]
                for i in 0...temperatureСondition.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, temperatureСondition[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
            
            case 19:
                let dressStructuralElements = ["2 в 1","баска","без разреза","бретели","внутренняя сетка","волан","вырез на спинке","капюшон","карман","кокетка","корсет","кулиска","манежы","нет","отрезной лиф","подплечники","подтяжки","подъюбник","прозрачные вставки","пуш-ап","регулируемные бретели","с разрезом","снегозащитная юбка","съемные бретели","съемные рукава","съемный воротник","трансформер","шлевки","шлейф","шлица"]
                for i in 0...dressStructuralElements.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, dressStructuralElements[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
                
            case 20:
                let shoeLiningMaterial = ["без подкладки","искусственная кожа","искусственный материал","натуральная кожа","полиуретан","полиэстер","синтетическая кожа","синтетическая ткань","текстиль"]
                for i in 0...shoeLiningMaterial.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, shoeLiningMaterial[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 21:
                let shoeSoleMaterial = ["искусственный материал","каучук термопластичный","каучук","натуральная кожа","ПВХ","полимер","полиуретан","резина","термопласт","ТПР","ТПУ","тунит","ТЭП (термпоэластопласт)","ЭВА (этиленвинилацетат)"]
                for i in 0...shoeSoleMaterial.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, shoeSoleMaterial[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 23:
                let insoleMaterial = ["без стельки","искусственная кожа","искусственный материал","натуральная замша","натуральная кожа","натуральный мех","полиуретан","спилок","текстиль","термопласт","хлопок","ЭВА"]
                for i in 0...insoleMaterial.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, insoleMaterial[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 26:
                let skirtModel = ["без юбки","в складку","карандаш","облегающая","пачка","плиссированная","прямая","трапеция","широкая"]
                for i in 0...skirtModel.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, skirtModel[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 27:
                let skirtLength = ["Мини", "Макси", "Миди"]
                for i in 0...skirtLength.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, skirtLength[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 28:
                let jeansModel = ["бойфренды","джоггеры","зауженные","клеш","прямые","скинни","широкие"]
                for i in 0...jeansModel.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, jeansModel[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 29:
                let jeansFeatures = ["без швов","вареный эффект","двойная застежка","для роддома","дышаший материал","нескользящее покрытие","нет","открытые срезы","перманентные складки","плоские швы","рваные","с лампасами","с молнией сзади","с утеплением","спа эффект","укороченная","устойчивость к истиранию","эластичный материал","эргономичный крой","эффект потертости"]
                for i in 0...jeansFeatures.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, jeansFeatures[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
                
            case 30:
                let trouserModelPantsCut = ["облегающий","прямой","широкий"]
                for i in 0...trouserModelPantsCut.count-1 {
                    let _ = SubfilterModel1(lastSID, filterId, trouserModelPantsCut[i], categoryId, &lastSID, subfiltersByFilter: &subfiltersByFilter, firebaseTemplate: self)
                }
            default: continue
                
            }
        }
        return  (lastSID, subfiltersByFilter)
    }
    
    
    
    
    
    func uploadSubfiltersByItem(categoryId: Int,
                                colorByItem: [Int:Int],
                                subfiltersFilter: [Int:[Int]],
                                multiFilter: [Int: Int],
                                brandsSubfilters: [Int]) {
        

        var subfilterLastUsed:[Int: Int] = [:]
        var nextIdx = 0
        for (itemId, colorId) in colorByItem {
            
            var subfilters4Item: [Int] = []
            subfilters4Item.append(colorId)
            
            for (key, val) in subfiltersFilter {
                let filterId = key
                let subfilters = val
                let isMulti = multiFilter[filterId]!
                
                if isMulti == 1{
                    for id in subfilters {
                        subfilters4Item.append(id)
                    }
                } else {
                    var nextIdx = subfilterLastUsed[key] ?? 0
                    if nextIdx > subfilters.count - 1 {
                        nextIdx = 0
                    }
                    
                    subfilters4Item.append(subfilters[nextIdx])
                    subfilterLastUsed[key] = nextIdx + 1
                }
            }
            
            
            
            if nextIdx > brandsSubfilters.count - 1 {
                nextIdx = 0
            }
            subfilters4Item.append(brandsSubfilters[nextIdx])
            nextIdx += 1
            
            createItem(item: itemId,  subfilters: subfilters4Item, categoryId: categoryId)
        }
    }
    
    func uidModelFirebaseStore(uidModel: UidModel) {
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("uids")
        let itemsRef = childRef.child("uid_\(uidModel.uid)")
        itemsRef.setValue(["type": uidModel.type,
                           "uid": uidModel.uid,
                           "cross": uidModel.cross,
                           "filterId": uidModel.filterId,
                           "categoryId": uidModel.categoryId])
    }
    
    
    func catalogFirebaseStore(catalog: CatalogModel1){
        let rootRef = Database.database().reference()
        var childRef = rootRef.child("pricesByItem")
        var itemsRef = childRef.child("item\(catalog.id)")
        itemsRef.setValue(["categoryId": catalog.categoryId, "id": catalog.id, "price": catalog.newPrice])
        
        childRef = rootRef.child("catalog")
        itemsRef = childRef.child("item\(catalog.id)")
        let dict = getCatalogDictionary(catalog: catalog)
        itemsRef.setValue(dict)
    }
    
    private func getCatalogDictionary(catalog: CatalogModel1)->[String: Any]  {
        return ["id": catalog.id, "categoryId": catalog.categoryId, "name":catalog.name, "thumbnail":catalog.thumbnail, "stars":catalog.stars, "newPrice":catalog.newPrice, "oldPrice":catalog.oldPrice, "votes":catalog.votes, "discount":catalog.discount]
    }
    
    
    
    
    func filterUpload(filter: FilterModel1){
        filters[filter.id] = filter
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("filters")
        let itemsRef = childRef.child("filter\(filter.id)")
        let dict = getFilterDictionary(filter: filter)
        itemsRef.setValue(dict)
    }
    
    private func getFilterDictionary(filter: FilterModel1)->[String: Any]  {
        return ["id": filter.id, "title":filter.title, "categoryId":filter.categoryId, "enabled":filter.enabled, "filterEnum":filter.filterEnum.rawValue, "cross": filter.cross, "uuid": filter.uuid]
    }
    
    
    
    
    private func addSubfiltersByFilter(filterId:Int, subfilterId: Int){
        if subfiltersByFilter[filterId] == nil {
            subfiltersByFilter[filterId] = []
        }
        subfiltersByFilter[filterId]?.append(subfilterId)
    }
    
    private func addSubFilter(subFilter: SubfilterModel1){
        subFilters[subFilter.id] = subFilter
    }
    
    private func getSubFilterDictionary(subFilter: SubfilterModel1)->[String: Any]  {
        return ["categoryId": subFilter.categoryId, "id": subFilter.id, "filterId":subFilter.filterId, "title":subFilter.title, "enabled":subFilter.enabled, "sectionHeader":subFilter.sectionHeader, "cross":subFilter.cross]
    }
    
    private func subfilterFirebaseStore(subFilter: SubfilterModel1){
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("subfilters")
        let itemsRef = childRef.child("subfilter\(subFilter.id)")
        let dict = getSubFilterDictionary(subFilter: subFilter)
        itemsRef.setValue(dict)
    }
    
    func subfilterUpload(subFilter: SubfilterModel1){
        addSubFilter(subFilter: subFilter)
        addSubfiltersByFilter(filterId: subFilter.filterId, subfilterId: subFilter.id)
        subfilterFirebaseStore(subFilter: subFilter)
    }
    
    
    
    
    private func createItem(item: Int, subfilters: [Int], categoryId: Int){
        let _ = Item(id: item, subfilters: subfilters, categoryId: categoryId, firebaseTemplate: self)
        subfiltersByItem[item] = subfilters
    }
    
    
    
    
    func addItemsBySubfilter(item: Item, subfilters: [Int]){
        subfilters.forEach{ id in
            if itemsBySubfilter[id] == nil {
                itemsBySubfilter[id] = []
                itemsBySubfilter[id]?.append(item)
            } else {
                itemsBySubfilter[id]?.append(item)
            }
        }
    }
    
    
    func itemUpload(item: Item, subfilters: [Int]) {
        
        addItemsBySubfilter(item: item, subfilters: subfilters)
        let rootRef = Database.database().reference()
        let childRef = rootRef.child("subfiltersByItem")
        let itemsRef = childRef.child("item\(item.id)")
        let dict = getItemDictionary(itemId: item.id, categoryId: item.categoryId, subfilters: subfilters)
        itemsRef.setValue(dict)
    }
    
    
    
    func getItemDictionary(itemId: Int, categoryId: Int, subfilters: [Int])->[String: Any]  {
        return ["categoryId": categoryId, "id": itemId, "subfilters": subfilters]
    }
    
    
    
    
    func uploadCatalog(categoryId: Int, imageByItem: [Int:String], minPrice: Int, maxPrice: Int){
        for (itemId, imageName) in imageByItem {
            let oldPrice = Int.random(in: minPrice...maxPrice)
            var discount = Int.random(in: 5...40)
            var newPrice = oldPrice * discount / 100
            if newPrice < minPrice {
                newPrice = minPrice
                discount = (oldPrice/newPrice - 1) * 100
            }
            let votes = Int.random(in: 2...1000)
            let stars = Int.random(in: 0...5)
            let _ = CatalogModel1(id: itemId,
                                  categoryId: categoryId,
                                  name: "",
                                  thumbnail: imageName,
                                  stars: stars,
                                  newPrice: newPrice,
                                  oldPrice: oldPrice,
                                  votes: votes,
                                  discount: discount,
                                  subfiltersByItem: subfiltersByItem,
                                  subFilters: subFilters,
                                  firebaseTemplate: self
                                  )
        }
    }
    
    

    
    
    
    func cleanupFirebase(){
        let rootRef = Database.database().reference()
        var ref = rootRef.child("catalog");
        ref.removeValue()
        
        ref = rootRef.child("filters");
        ref.removeValue()
        
        ref = rootRef.child("uids");
        ref.removeValue()
        
        ref = rootRef.child("itemsBySubfilter");
        ref.removeValue()
        
        ref = rootRef.child("subfilters");
        ref.removeValue()
        
        ref = rootRef.child("subfiltersByFilter");
        ref.removeValue()
        
        ref = rootRef.child("subfiltersByItem");
        ref.removeValue()
        
        ref = rootRef.child("pricesByItem");
        ref.removeValue()
        
        ref = rootRef.child("rangePriceByCategory");
        ref.removeValue()
        
        ref = rootRef.child("categories");
        ref.removeValue()
    }
    
    
    func finalUpload(_ categoryId: Int, minPrice: CGFloat, maxPrice: CGFloat){
        
        // itemsBySubfilter
        let rootRef = Database.database().reference()
        var childRef = rootRef.child("itemsBySubfilter")
   
        for (key, items) in itemsBySubfilter.filter({subFilters[$0.key]?.cross == true}) {
            let itemsRef = childRef.child("subfilter\(key)_\(categoryId)")
            let ids = items.filter({$0.categoryId == categoryId}).compactMap({$0.id})
            let title = subFilters[key]?.title
            itemsRef.setValue(["categoryId": categoryId, "id": key, "items": ids, "name":title])
        }
        
        
        for (key, items) in itemsBySubfilter.filter({subFilters[$0.key]?.categoryId == categoryId}) {
            let itemsRef = childRef.child("subfilter\(key)_\(categoryId)")
            let ids = items.filter({$0.categoryId == categoryId}).compactMap({$0.id})
            let title = subFilters[key]?.title
            itemsRef.setValue(["categoryId": categoryId, "id": key, "items": ids, "name":title])
        }
        
        //rangePriceByCategory
        childRef = rootRef.child("rangePriceByCategory")
        let itemsRef = childRef.child("category\(categoryId)")
        itemsRef.setValue(["id": categoryId, "minPrice": minPrice, "maxPrice": maxPrice])
        
        
       childRef = rootRef.child("subfiltersByFilter")
       for (key, val) in subfiltersByFilter {
            let filter = filters[key]
            if filter?.categoryId == categoryId {
                let itemsRef = childRef.child("filter\(key)")
                itemsRef.setValue(["id": key, "subfilters": val])
            }
       }
    }
    
}

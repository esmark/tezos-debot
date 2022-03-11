pragma ton-solidity >=0.57.3;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "./interfaces/Debot.sol";
import "./interfaces/AddressInput/AddressInput.sol";
import "./interfaces/Menu/Menu.sol";
import "./interfaces/Network/Network.sol";
import "./interfaces/QRCode/QRCode.sol";
import "./interfaces/Terminal/Terminal.sol";
import "./interfaces/UserInfo/UserInfo.sol";


contract TezosContract is Debot {
    bytes m_icon;
    uint256 m_pubkey; //my Everscale pubkey
    string tezos_address; //Tezos address
    string tezos_public_key; //Tezos public key
    string tezos_private_key; //Tezos private key

    mapping(uint256 => string) default_tezos_address;

    string constant DOMAIN = "https://rpc.hangzhounet.teztnets.xyz/"; //set test or main Tezos RPC domain

	modifier checkPubkey {
		// Check that message public key is set
		require(msg.pubkey() != 0, 101);
		tvm.accept();
		_;
	}

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function setDefaultTezosAddress(string value) public checkPubkey {
        require(value.byteLength() == 36, 102);
        uint256 msg_pubkey = msg.pubkey();
        default_tezos_address[msg_pubkey] = value;
    }

    function start() public override {
        UserInfo.getPublicKey(tvm.functionId(setDefaultPubkey));
        mainMenu();
    }

    function mainMenu() private inline {
        Menu.select("Menu", "Select item", [
            MenuItem("Address", "Input Tezos address", tvm.functionId(menuAddress)),
            MenuItem("Balance", "Check balance XTZ", tvm.functionId(menuBalance)),
            MenuItem("Send", "Send transaction to the address", tvm.functionId(menuSend)),
            MenuItem("Info", "Get Tezos address by default", tvm.functionId(getInfo))
            //MenuItem("Setting", "Set Tezos address by default", tvm.functionId(menuSetting))
        ]);
    }

    function menuAddress() public {
        getTezosAddress();

        if (tezos_address != "") {
            Terminal.print(0, format("Tezos address is {}. Reset it?", tezos_address));
        }
        
        Terminal.input(tvm.functionId(setTezosAddress), "Enter Tezos address", false);
    }

    function menuBalance() public {
        getTezosAddress();

        if (tezos_address == "") {
            Terminal.input(tvm.functionId(setTezosAddress), "Firstly enter Tezos address", false);
        }
        else {
            Terminal.print(0, format("Checking Tezos address {} ...", tezos_address));
            string[] headers;
            string url = DOMAIN + "chains/main/blocks/head/context/contracts/";
            url += tezos_address; //url += "tz1aWXP237BLwNHJcCD4b3DutCevhqq2T1Z9";
            url += "/balance";

            Network.get(tvm.functionId(getBalanceResponse), url, headers);
        }
    }

    function menuSend() public {
        getTezosAddress();

        if (tezos_address == "") {
            Terminal.input(tvm.functionId(setTezosAddress), "Firstly enter Tezos address", false);
        }
        else {
            Terminal.print(0, format("Sending from Tezos address {} ...", tezos_address));
            string[] headers;
            string url = DOMAIN + "chains/main/blocks/head/context/contracts/";
            url += tezos_address;
            //url += "/balance"; //tz2VYjhQNT7DmKeYu3UgUgFjsToaNwEAJiC6
            
            // TODO: continue here
            //headers.push("Content-Type: application/x-www-form-urlencoded");
            //Network.get(tvm.functionId(getSendResponse), url, headers);
        } 
    }

    /*Temp deploy function*/
    /* function settingTezosAddress(string value) public {
        //require(value != "", 102);
        if (value.byteLength() == 36) { //correct Tezos address length

            setTezosAddress(value);
        }
        else {
            //Terminal.input(tvm.functionId(settingTezosAddress), "Please enter correct Tezos address", false);
            Terminal.print(0, "Failed to save Tezos Address. Please input correct address");

            mainMenu();
        }
    } */

    function getTezosAddress() public {

        if (m_pubkey != 0 && default_tezos_address[m_pubkey] != "") {
            tezos_address = default_tezos_address[m_pubkey];
        }
        
    }

    function setTezosAddress(string value) public {
        require(value != "", 102);

        if (value.byteLength() == 36) { //correct Tezos address length

            Terminal.print(0, format("Current Tezos Address: {}", value));
            tezos_address = value;
        }
        else {

            Terminal.print(0, "Failed to save Tezos Address. Please input correct address");
        }

        mainMenu();
    }

    /*Temp function*/
    function getInfo() public {

        Terminal.print(0, format("tvm.pubkey: {}", tvm.pubkey()));
        Terminal.print(0, format("m_pubkey: {}", m_pubkey));
        Terminal.print(0, format("tezos_address: {}", tezos_address));
        Terminal.print(0, format("tezos_address_default: {}", default_tezos_address[m_pubkey]));

        mainMenu();
    }

    function getBalanceResponse(int32 statusCode, string[] retHeaders, string content) public {
        if(statusCode == 200) {

            Terminal.print(0, format("Balance: {} micro XTZ", content));
        }
        else {

            Terminal.print(0, format("Please fix and try again. \nError: {}", statusCode));
        }

        mainMenu();
    }

    function getSendResponse(int32 statusCode, string[] retHeaders, string content) public {
        require(statusCode == 200, 105);
        // TODO: analyze headers.
        for (string hdr: retHeaders) {
            Terminal.print(0, hdr);
        }
        // TODO: deserialize content from json to structure using Json interface.
        Terminal.print(0, format("Send to {} micro XTZ", content));

        mainMenu();
    }

    function setDefaultPubkey(uint256 value) public {
        m_pubkey = value;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [Menu.ID, Network.ID, UserInfo.ID, Terminal.ID];
    }

    function getDebotInfo() public functionID(0xDEB) view override returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon) {
        name = "Tezos Wallet DeBot";
        version = "0.0.5";
        publisher = "Equity philosophers, https://t.me/+jyUzooqHDps3MDgy";
        author = "Kamil Khadeyev, https://t.me/kamil39";
        support = address(0);
        hello = "Hello, I'm a Debot Tezos Wallet. I can check Balance and Send transations. Please select a Menu Item.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
}
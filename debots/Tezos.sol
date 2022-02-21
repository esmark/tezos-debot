pragma ton-solidity >=0.40.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "./interfaces/Debot.sol";
import "./interfaces/AddressInput/AddressInput.sol";
import "./interfaces/Menu/Menu.sol";
import "./interfaces/Network/Network.sol";
import "./interfaces/Terminal/Terminal.sol";
import "./interfaces/UserInfo/UserInfo.sol";

contract TezosContract is Debot {
    bytes m_icon;
    address m_wallet; //

    mapping(address => string) tezos_wallet;
    //uint8 constant DECIMAL = 6;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function start() public override {
        mainMenu();
    }

    function mainMenu() private inline {
        Menu.select("Menu", "Select item", [
            MenuItem("Address", "Input Tezos address", tvm.functionId(menuAddress)),
            MenuItem("Balance", "Check balance XTZ", tvm.functionId(menuBalance)),
            MenuItem("Send", "Send transaction to the address", tvm.functionId(menuSend))
        ]);
    }

    function menuAddress() public {
        AddressInput.get(tvm.functionId(setTezosAddress), "Enter Tezos wallet address:");
        // TODO: continue here
    }

    function menuBalance() public {
        // TODO: continue here
        string[] headers;
        string url = "https://rpc.hangzhounet.teztnets.xyz/chains/main/blocks/head/context/contracts/";
        url += "tz1aWXP237BLwNHJcCD4b3DutCevhqq2T1Z9";
        url += "/balance";
        //headers.push("Content-Type: application/x-www-form-urlencoded");
        Network.get(tvm.functionId(setResponse), url, headers);
    }

    function menuSend() public {
        // TODO: continue here
        UserInfo.getAccount(tvm.functionId(setDefaultAccount));
    }

    function setTezosAddress(address value, string tezos_address) public {
        // TODO: continue here 
        tezos_address = "tz1aWXP237BLwNHJcCD4b3DutCevhqq2T1Z9";
        tezos_wallet[value] = tezos_address;
        Terminal.print(0, format("Tezos account {}", tezos_address));
    }

    function setDefaultAccount(address value) public {
        Terminal.print(0, format("User account {}", value));
        m_wallet = value;
    }

    function setResponse(int32 statusCode, string[] retHeaders, string content) public {
        require(statusCode == 200, 101);
        // TODO: analyze headers.
        /* for (string hdr: retHeaders) {
            Terminal.print(0, hdr);
        } */
        // TODO: deserialize content from json to structure using Json interface.
        //uint256 mod_contant = content * DECIMAL;
        Terminal.print(0, content);
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ AddressInput.ID, Menu.ID, Network.ID, UserInfo.ID, Terminal.ID];
    }

    function getDebotInfo() public functionID(0xDEB) view override returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon) {
        name = "Tezos RPC Json DeBot";
        version = "0.0.1";
        publisher = "Equity philosophers";
        key = "Tezos RPC Json DeBot";
        author = "Equity philosophers";
        support = address(0);
        hello = "Please select a Menu Item.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
}
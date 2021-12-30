pragma solidity >=0.4.22 <0.6.0; //0.5.1
pragma experimental ABIEncoderV2;

//import "./safemath.sol";

contract Dup {
    //string pk;
    uint n = 3;//允许n个计算者
    string state;
    uint gasLimit = 7000000; 
    uint gasPrice = 1;
    uint reward = 0.01 ether;
    uint deposit;
    
    struct CT{
        uint C1x;
        uint C1y;
        uint C2x;
        uint C2y;
        uint C3x;
        uint C3y;
    }
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    G2Point private g = G2Point([2556360995629148574228678374677572145872318590147675934027520210059089695539,0],[2462293571245650981359076708306740352790454989090202702561999220257347750670,0]);
    G1Point private pk = G1Point(733479471311726715863616764265852037863442473831086978366175344434859155760,796415263232853222103437214993950903560448683601182754563592752976630093171);
    address[3] private contractors = [0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2];//计算者地址存放数组
    CT[3] private ct;//计算者结果存放数组
    CT private ct1;
    G1Point[6] private g1;
    G2Point[6] private g2;
    
    uint count1 = 0;
    uint flag =0;
    uint[3] justify = [0,0,0];//判断最终正确值并记录计算者次数

    CT private trueResult;//正确结果
    address[3] CorrectCons;//正确计算者地址
    uint[][] public log= new uint[][](0);//相同结果的计算者
    uint num=0;uint256 t1=0;
    uint temp=0;
    uint tempk=0;
    G1Point private pk2;
    uint256[6][3] ctResult=[[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]];
    
    //字符串比较
    function hashCompareInternal(string memory a, string memory b) public view returns (bool) {
        return (keccak256(bytes(a)) == keccak256(bytes(b)));
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function getAddress() public view returns(address){
        return msg.sender;
    }
    function getCT(uint nn) public view returns(uint){
        return ct[nn].C1x;
    }
    
    function P2() internal returns (G2Point memory) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
            10857046999023057135944570762232829481370756359578518086990519993285655852781],

            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
            8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    
    function init() public payable{
        state="Init";
    }
    function create() public payable returns(bool){
        if(hashCompareInternal(state,"Init")!=true) {
            return false;
        }
        else if (msg.sender.balance < (deposit+gasPrice*gasLimit)){
            return false;
        }
        else {
            state = "Created";
            return true;
        }
    }

    function uploadCT(uint256 c1x,uint256 c1y,uint256 c2x,uint256 c2y,uint256 c3x,uint256 c3y) public returns(bool){
        if(hashCompareInternal(state,"Created")!=true){
            return false;
        }
        else if(count1==3){
            return false;
        }else{
            ct[count1].C1x=c1x;
            ct[count1].C1y=c1y;
            ct[count1].C2x=c2x;
            ct[count1].C2y=c2y;
            ct[count1].C3x=c3x;
            ct[count1].C3y=c3y;
            contractors[count1] = msg.sender;
            count1++;
            state = "CT_uploaded";
            return true;
        }
    }
    
    // function test(G1Point[3] memory g11, G2Point[3] memory g22) public returns(uint){

    //     return m;
        
    // }
    
    G1Point[3] private g11;
    G2Point[3] private g22;
    
    function test(G1Point memory g21, G1Point memory g22, G1Point memory g23, G2Point memory g11, G2Point memory g12, G2Point memory g13) public returns(bool){
        if(hashCompareInternal(state,"CT_uploaded")!=true){
            return false;
        }
        
        else if(pairing2(g21, g, pk, g11)){
            trueResult=ct[0];
            transfer(contractors[0],reward);
            transfer(contractors[1],reward);
            if(pairing2(g22, g, pk, g12)){
                transfer(contractors[2],reward);
            }
        }
        else if(pairing2(g23, g, pk, g13)){
            trueResult=ct[0];
            transfer(contractors[0],reward);
            transfer(contractors[2],reward);
        }
        else{
            trueResult=ct[1];
            transfer(contractors[1],reward);
            transfer(contractors[2],reward);
        }
    }

    function Test1(uint256 d12x,uint256 d12y,uint256 d13x,uint256 d13y,uint256 d23x,uint256 d23y) public{
        g22[0].X[0] = d12x;
        g22[0].X[1] = 0;
        g22[0].Y[0] = d12y;
        g22[0].Y[1] = 0;
        g22[1].X[0] = d13x;
        g22[1].X[1] = 0;
        g22[1].Y[0] = d13y;
        g22[1].Y[1] = 0;
        g22[2].X[0] = d23x;
        g22[2].X[1] = 0;
        g22[2].Y[0] = d23y;
        g22[2].Y[1] = 0;
    }
    
    function Test2(uint256 a12x,uint256 a12y, uint256 a13x, uint256 a13y, uint256 a23x,uint256 a23y) public returns(bool){
        g11[0].X = a12x;
        g11[0].Y = a12y;
        g11[1].X = a13x;
        g11[1].Y = a13y;
        g11[2].X = a23x;
        g11[2].Y = a23y;
        
        // uint temp2=0;
        // uint m=0;
        
        bytes memory message = hex"7b0a2020226f70656e223a207b0a20202020227072696365223a2039353931372c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333134323430302c0a2020202020202269736f223a2022323031362d31322d33315430303a30303a30302e3030305a220a202020207d0a20207d2c0a202022636c6f7365223a207b0a20202020227072696365223a2039363736302c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d2c0a2020226c6f6f6b7570223a207b0a20202020227072696365223a2039363736302c0a20202020226b223a20312c0a202020202274696d65223a207b0a20202020202022756e6978223a20313438333232383830302c0a2020202020202269736f223a2022323031372d30312d30315430303a30303a30302e3030305a220a202020207d0a20207d0a7d0a6578616d706c652e636f6d2f6170692f31";

        G1Point memory signature = G1Point(11181692345848957662074290878138344227085597134981019040735323471731897153462, 6479746447046570360435714249272776082787932146211764251347798668447381926167);

        G2Point memory v = G2Point(
            [18523194229674161632574346342370534213928970227736813349975332190798837787897, 5725452645840548248571879966249653216818629536104756116202892528545334967238],
            [3816656720215352836236372430537606984911914992659540439626020770732736710924, 677280212051826798882467475639465784259337739185938192379192340908771705870]
        );

       // G1Point memory h = hashToG1(message);
        
        if(pairing2(signature, P2(), signature, v)){
            trueResult=ct[0];
            transfer(contractors[0],reward);
            transfer(contractors[1],reward);
            if(pairing2(g11[1],g,pk2,g22[1])){
                transfer(contractors[2],reward);
            }
        }
        else if(pairing2(signature, P2(), signature, v)){
            trueResult=ct[0];
            transfer(contractors[0],reward);
            transfer(contractors[2],reward);
        }
        else{
            trueResult=ct[1];
            transfer(contractors[1],reward);
            transfer(contractors[2],reward);
        }
        
        // for(uint i=0;i<2;i++){
        //     for(uint j=i+1;j<3;j++){
        //         if(pairing2(g11[temp2],g,pk2,g22[temp2])){//预编译合约判断占位
        //             justify[i]++;
        //             justify[j]++;
        //             temp2++;
        //             if(justify[i]>=2){
        //                 m=i;
        //             }
        //             else if(justify[j]>=2){
        //                 m=j;
        //             }
        //         }
        //     }
        // }
        // flag=justify[0];
        // for(uint k=1;k<3;k++){
        //     if(flag<justify[k]){
        //         flag=justify[k];
        //         m=k;
        //     }
        // }
        
        // trueResult=ct[m];
        
        // if(m==0){
        //     transfer(contractors[m],reward);
        //     if(pairing2(g11[0],g,pk2,g22[1])){
        //         transfer(contractors[1],reward);
        //     }
        //     if(pairing2(g11[0],g,pk2,g22[2])){
        //         transfer(contractors[2],reward);
        //     }
        // }
        // else if(m==1){
        //     transfer(contractors[m],reward);
        //     if(pairing2(g11[0],g,pk2,g22[1])){
        //         transfer(contractors[0],reward);
        //     }
        //     if(pairing2(g11[1],g,pk2,g22[2])){
        //         transfer(contractors[2],reward);
        //     }
        // }
        // else if(m==2){
        //     transfer(contractors[m],reward);
        //     if(pairing2(g11[0],g,pk2,g22[2])){
        //         transfer(contractors[0],reward);
        //     }
        //     if(pairing2(g11[1],g,pk2,g22[2])){
        //         transfer(contractors[1],reward);
        //     }
        // }
        return true;
    }
    function transfer(address _to, uint256 _value) payable public {
        address(uint160(_to)).transfer(_value);
        return;
    }

    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas(), 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    
    function pairing2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
}
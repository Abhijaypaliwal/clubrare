pragma solidity ^0.8.14;


contract demoArr {

    uint[] arr1=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,23,23,23,232,32,3,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,2323,23,23,23,23,23,232];

    function WithoutCache() public  {

        uint num;

        for(uint i=0;i< arr1.length;i++) {

            num+=i;


        }

    }

    function Cache() public {

        uint num;
        uint temp=arr1.length;

        for(uint i=0;i< temp;i++) {

            num+=i;


        }

    }
}

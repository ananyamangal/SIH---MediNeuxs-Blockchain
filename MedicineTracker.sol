// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedicineTracker {
    struct Medicine {
        string name;
        string batchId;
        string manufacturer;
        uint256 manufacturingDate;
        uint256 expiryDate;
        address[] journey; // Array to track the journey of the medicine
    }

    mapping(string => Medicine) public medicines; // Mapping to store medicines by their batch ID
    mapping(address => bool) public authorizedEntities; // Mapping to store authorized entities

    address public owner;

    // Events
    event MedicineRegistered(
        string batchId,
        string name,
        string manufacturer,
        uint256 manufacturingDate,
        uint256 expiryDate
    );

    event SupplyChainUpdated(string batchId, address indexed entity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyAuthorized() {
        require(
            authorizedEntities[msg.sender],
            "Only authorized entities can perform this action"
        );
        _;
    }

    constructor() {
        owner = msg.sender; // Set the deployer as the owner
        authorizedEntities[msg.sender] = true; // The owner is an authorized entity by default
    }

    // Function to add authorized entities
    function addAuthorizedEntity(address _entity) public onlyOwner {
        authorizedEntities[_entity] = true;
    }

    // Function to remove authorized entities
    function removeAuthorizedEntity(address _entity) public onlyOwner {
        authorizedEntities[_entity] = false;
    }

    // Function to register a new medicine
    function registerMedicine(
        string memory _batchId,
        string memory _name,
        string memory _manufacturer,
        uint256 _manufacturingDate,
        uint256 _expiryDate
    ) public onlyAuthorized {
        // Ensure the medicine is not already registered
        require(
            medicines[_batchId].journey.length == 0,
            "Medicine already registered"
        );

        // Register the medicine with an empty journey array
        medicines[_batchId] = Medicine({
            name: _name,
            batchId: _batchId,
            manufacturer: _manufacturer,
            manufacturingDate: _manufacturingDate,
            expiryDate: _expiryDate,
            journey:new address[](0)
        });

        emit MedicineRegistered(
            _batchId,
            _name,
            _manufacturer,
            _manufacturingDate,
            _expiryDate
        );
    }

    // Function to update the supply chain
    function updateSupplyChain(string memory _batchId) public onlyAuthorized {
        // Ensure the medicine is registered
        require(
            medicines[_batchId].journey.length > 0,
            "Medicine not registered"
        );

        // Add the current address to the medicine's journey
        medicines[_batchId].journey.push(msg.sender);

        emit SupplyChainUpdated(_batchId, msg.sender);
    }

    // Function to get medicine details
    function getMedicineDetails(string memory _batchId)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            uint256,
            uint256,
            address[] memory
        )
    {
        Medicine memory med = medicines[_batchId];
        return (
            med.name,
            med.batchId,
            med.manufacturer,
            med.manufacturingDate,
            med.expiryDate,
            med.journey
        );
    }
}

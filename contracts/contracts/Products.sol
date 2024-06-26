// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Products {
    struct Product {
        uint256 id;
        string productName;
        string description;
        uint256 price;
        string[] images;
        uint256 rating;
        uint256 categoryId;
    }
    
    uint256 public productCount;
    address public owner;
    Product[] public products;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    //Event
    event created(
        uint256 id,
        string productName,
        string description,
        uint256 price
    );
    event edited(
        uint256 id,
        string productName,
        string description,
        uint256 price
    );
    event deleted(uint256 id);

    //For product

    function addProduct(
        string memory _productName,
        string memory _description,
        uint256 _price,
        string[] memory _inputImages,
        uint256 _catergoryId
    ) external {
        uint256 index;
        bool check = false;
        for (uint256 i = 0; i < products.length; i++) {
            if (products[i].id == 0) {
                index = i;
                check = true;
                break;
            }
        }

        Product memory newProduct = Product(
            ++productCount,
            _productName,
            _description,
            _price,
            _inputImages,
            0,
            _catergoryId
        );

        if (check) {
            products[index] = newProduct;
        } else {
            products.push(newProduct);
        }

        //Thêm 1 event vào để thông báo rằng đã thêm thành công
        emit created(productCount, _productName, _description, _price);
    }

    function getAllProducts() public view returns (Product[] memory) {
        Product[] memory tmp = new Product[](productCount); // Khởi tạo mảng với độ dài là length
        for (uint256 i = 0; i < productCount; i++) {
            tmp[i] = products[i];
        }
        return tmp;
    }

    function getProductById(uint256 _id) public view returns (Product memory) {
        return getProduct(_id);
    }

    function getProductByCategoryId(uint256 _id)
        external
        view
        returns (Product[] memory)
    {
        uint count = 0;
         for (uint256 i = 0; i < productCount; i++) {
            if (products[i].categoryId == _id) {
                count++;
            }
        }

        uint index = 0;
        Product[] memory tmp = new Product[](count);
        for (uint256 i = 0; i < productCount; i++) {
            if (products[i].categoryId == _id) {
                tmp[index] = products[i]; index++;
            }
        }
        return tmp;
    }

    //internal function
    function getProduct(uint256 _id) internal view returns (Product storage) {
        for (uint256 i = 0; i < productCount; i++) {
            if (products[i].id == _id) {
                return products[i];
            }
        }
        // Nếu không tìm thấy sản phẩm, trả về một sản phẩm rỗng
        revert("Product not found");
    }

    function editProduct(
        uint256 _id,
        string memory _productName,
        string memory _description,
        uint256 _price,
        string[] memory _inputImages,
        uint256 _categoryId
    ) external {
        require(_id <= productCount, "Invalid product ID");
        Product storage oldProduct = getProduct(_id);
        require(oldProduct.id != 0, "Product does not exist");

        oldProduct.productName = _productName;
        oldProduct.description = _description;
        oldProduct.price = _price;
        oldProduct.images = _inputImages;
        oldProduct.categoryId = _categoryId;

        //Thêm 1 event vào để thông báo rằng đã sửa thành công
        emit edited(_id, _productName, _description, _price);
    }

    function deleteProduct(uint256 _id) external {
        require(_id <= productCount, "Invalid product ID");

        Product memory tmp = getProduct(_id);
        require(tmp.id != 0, "Product does not exist");

        // Xóa sản phẩm bằng cách đẩy các phần tử phía sau lên trước
        for (uint256 i = _id - 1; i < productCount - 1; i++) {
            products[i] = products[i + 1];
            products[i].id--;
        }

        //Xoa san pham o cuoi cung
        delete products[productCount - 1];
        productCount--;

        //Thêm 1 event vào để thông báo rằng đã xóa thành công
        emit deleted(_id);
    }

    function deleteAllProducts(
    ) external {
        productCount = 0;
        delete products;
    }
}

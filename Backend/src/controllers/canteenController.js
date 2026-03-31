const CanteenItem = require('../models/CanteenItem');

exports.getCanteenMenu = async (req, res) => {
  try {
    const items = await CanteenItem.find({ available: true });
    
    // Group by category
    const menu = {};
    items.forEach(item => {
      if (!menu[item.category]) {
        menu[item.category] = [];
      }
      menu[item.category].push({
        name: item.name,
        price: item.price,
        description: item.description
      });
    });
    
    const menuArray = Object.keys(menu).map(category => ({
      category,
      items: menu[category]
    }));
    
    res.status(200).json({ success: true, data: menuArray });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
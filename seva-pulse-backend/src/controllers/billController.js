const Bill = require('../models/Bill');

exports.getBills = async (req, res, next) => {
  try {
    const bills = await Bill.find().populate('patient appointment');
    res.status(200).json({ success: true, count: bills.length, data: bills });
  } catch (error) {
    next(error);
  }
};

exports.createBill = async (req, res, next) => {
  try {
    const bill = await Bill.create(req.body);
    res.status(201).json({ success: true, data: bill });
  } catch (error) {
    next(error);
  }
};

exports.payBill = async (req, res, next) => {
  try {
    const bill = await Bill.findByIdAndUpdate(
      req.params.id,
      { status: 'paid', paymentDate: Date.now(), paymentMethod: req.body.paymentMethod },
      { new: true }
    );
    if (!bill) {
      return res.status(404).json({ success: false, message: 'Bill not found' });
    }
    res.status(200).json({ success: true, data: bill });
  } catch (error) {
    next(error);
  }
};
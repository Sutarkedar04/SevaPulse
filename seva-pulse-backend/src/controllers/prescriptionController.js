const Prescription = require('../models/Prescription');

exports.getPrescriptions = async (req, res, next) => {
  try {
    const prescriptions = await Prescription.find().populate('doctor patient appointment');
    res.status(200).json({ success: true, count: prescriptions.length, data: prescriptions });
  } catch (error) {
    next(error);
  }
};

exports.createPrescription = async (req, res, next) => {
  try {
    const prescription = await Prescription.create(req.body);
    res.status(201).json({ success: true, data: prescription });
  } catch (error) {
    next(error);
  }
};

exports.getPrescriptionsByPatient = async (req, res, next) => {
  try {
    const prescriptions = await Prescription.find({ patient: req.params.patientId }).populate('doctor appointment');
    res.status(200).json({ success: true, data: prescriptions });
  } catch (error) {
    next(error);
  }
};
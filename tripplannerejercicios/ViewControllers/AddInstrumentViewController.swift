//
//  AddInstrumentViewController.swift
//  tripplannerejercicios
//
//  Created by MananasNew on 2/12/25.
//

import UIKit
import FirebaseFirestore

final class AddInstrumentViewController: UIViewController {

    @IBOutlet weak var marcaTextField: UITextField!
    @IBOutlet weak var modeloTextField: UITextField!

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nuevo Instrumento"
    }

    @IBAction func guardarTapped(_ sender: Any) {
        let marca = marcaTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let modelo = modeloTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !marca.isEmpty else {
            showMessage(message: "Ingresa la marca")
            return
        }
        guard !modelo.isEmpty else {
            showMessage(message: "Ingresa el modelo")
            return
        }

        // Generar ID de documento y persistir
        let docRef = db.collection("Instruments").document()
        let instrument = Instrument(id: docRef.documentID, marca: marca, modelo: modelo)

        do {
            try docRef.setData(from: instrument) { [weak self] error in
                if let error = error {
                    self?.showMessage(message: "Error al guardar: \(error.localizedDescription)")
                    return
                }
                self?.showMessage(message: "Instrumento guardado")
                self?.navigationController?.popViewController(animated: true)
            }
        } catch {
            showMessage(message: "Error de codificación: \(error.localizedDescription)")
        }
    }
}

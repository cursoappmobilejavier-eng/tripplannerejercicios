//
//   InstrumentsListViewController.swift
//  tripplannerejercicios
//
//  Created by MananasNew on 2/12/25.
//

import UIKit
import FirebaseFirestore

final class InstrumentsListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var instruments: [Instrument] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instrumentos"
        tableView.dataSource = self
        tableView.delegate = self

        // Botón para agregar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addInstrument)
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Escucha en tiempo real
        listener = db.collection("Instruments").addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                self?.showMessage(message: "Error al leer: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }

            do {
                self?.instruments = try documents.map { doc in
                    try doc.data(as: Instrument.self)
                }
                self?.tableView.reloadData()
            } catch {
                self?.showMessage(message: "Error al decodificar: \(error.localizedDescription)")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        listener = nil
    }

    @objc private func addInstrument() {
        // Navega a la pantalla de agregar
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddInstrumentViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension InstrumentsListViewController: UITableViewDataSource, UITableViewDelegate {
    // DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        instruments.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstrumentCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "InstrumentCell")

        let instrument = instruments[indexPath.row]
        cell.textLabel?.text = instrument.marca
        cell.detailTextLabel?.text = instrument.modelo
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // Delegate: ver detalle simple
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instrument = instruments[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let message = "ID: \(instrument.id)\nMarca: \(instrument.marca)\nModelo: \(instrument.modelo)"
        showMessage(title: "Instrumento", message: message)
    }
}

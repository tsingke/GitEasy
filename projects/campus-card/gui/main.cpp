#include "campus_window.hpp"
#include <QApplication>
#include <QTimer>
#include <iostream>
#include <stdexcept>
// 入口只组装应用和窗口；业务与界面实现分属独立编译单元。
int main(int argc, char **argv) {
    QApplication app(argc, argv);
    const auto args = app.arguments();
    const bool smoke = args.contains("--smoke-test");
    const int snapshotIndex = args.indexOf("--snapshot");
    const QString snapshot = snapshotIndex >= 0 ? args.value(snapshotIndex + 1) : QString();
    if (snapshotIndex >= 0 && snapshot.isEmpty()) {
        std::cerr << "--snapshot requires a PNG path\n";
        return 2;
    }
    CampusWindow window(smoke || !snapshot.isEmpty());
    window.show();
    if (smoke || !snapshot.isEmpty())
        QTimer::singleShot(0, &window, [&] {
            try {
                window.runSmokeTest();
                app.processEvents();
                if (!snapshot.isEmpty() && !window.grab().save(snapshot))
                    throw std::runtime_error("Cannot export GUI preview");
                app.exit(0);
            } catch (const std::exception &error) {
                std::cerr << error.what() << '\n';
                app.exit(1);
            }
        });
    return app.exec();
}

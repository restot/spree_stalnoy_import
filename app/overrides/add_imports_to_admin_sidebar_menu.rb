Deface::Override.new(
    virtual_path: 'spree/layouts/admin',
    name: 'stalnoy_import_admin_sidebar_menu',
    insert_bottom: '#main-sidebar',
    partial: 'spree/admin/shared/imports_sidebar_menu'
)
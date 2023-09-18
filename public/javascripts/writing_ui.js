class WritingUi {
    static makeEditor(writing_info) {
        return new toastui.Editor({
            el: document.querySelector('#editor')
            , initialValue: writing_info.body
            , usageStatistics: false
            , theme: 'dark'
            //, previewStyle: "vertical"
        });
    }

    static makeViewer(writing_info) {
        return new toastui.Editor({
            el: document.querySelector('#viewer')
            //, height: '600px'
            , viewer: true
            , initialValue: writing_info.body
            , usageStatistics: false
            , theme: 'dark'
        });
    }

    static view(writing_info) {
        return {
            padding: 10
            , rows: [{
                cols: [{ view: "label", template: writing_info.category }]
            },
            {
                view: "label", css: {
                    "font-size": "30px"
                }, template: writing_info.title
            },
            {
                cols: [{
                    rows: [{ view: "label", height: 20, template: writing_info.email },
                    { view: "label", template: writing_info.updatedAt }]
                }]
            },
            { view: "template", content: "writing_template" }
            ]
        }
    }

    static viewMenu(writing_info) {
        //delete confirm box view 
        let confirm_view = { title: "Delete", ok: "Yes", cancel: "No", text: l("Are sure delete ?") };
        return {
            cols: [{
                name: "", view: "button", label: l("list")
                , click: function (id, event) {
                    window.location.href = '/writing/list';
                }
            },
            {
                name: "", view: "button", label: l("edit")
                , click: function (id, event) {
                    window.location.href = `/writing/edit/${writing_info.id}`;
                }
            },
            {
                name: "", view: "button", label: l("delete")
                , click: function (id, event) {
                    webix.confirm(confirm_view).then(function () {
                        window.location.href = `/writing/delete/${writing_info.id}`;
                    });
                }
            }]
        };
    }

    static editMenu(writing_info) {

        return {
            cols: [{
                name: "save", view: "button", label: l("save")
                , click: function (id, event) {
                    //form데이터는 json으로 전송한다. 
                    var form_data = $$('edit_form').getValues();
                    form_data.body = md_editor.getMarkdown();
                    let requester = new Requester({
                        onOk: function (res) {
                            window.location.href = '/writing/list';
                        }
                    });
                    requester.post("/writing/api/save", form_data);
                }
            }, {
                name: "cancel", view: "button", label: l("cancel")
            }]
        }
    }

    static edit(writing_info) {
        return {
            view: "form", id: "writing:edit:menu"
            , elements: [{
                rows: [{ name: "writingId", view: "text", value: writing_info.id, hidden: true },
                { view: "text", name: "title", label: l("title"), value: writing_info.title },
                { view: "template", scroll: true, content: "writing_template" }
                ]
            }]
        };
    }
}//class
document.addEventListener('DOMContentLoaded', function() {
    // Elements
    const uploadArea = document.getElementById('upload-area');
    const fileInput = document.getElementById('file');
    const uploadText = document.getElementById('upload-text');
    const previewContainer = document.getElementById('image-preview-container');
    const imagePreview = document.getElementById('image-preview');
    const removeButton = document.getElementById('remove-image');
    const classifyBtn = document.getElementById('classify-btn');
    const modelBadges = document.querySelectorAll('.model-badge');
    
    // Handle file selection
    if (fileInput) {
        fileInput.addEventListener('change', handleFileSelect);
    }
    
    // Handle drag and drop
    if (uploadArea) {
        uploadArea.addEventListener('dragover', function(e) {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });
        
        uploadArea.addEventListener('dragleave', function() {
            uploadArea.classList.remove('dragover');
        });
        
        uploadArea.addEventListener('drop', function(e) {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            
            if (e.dataTransfer.files.length) {
                fileInput.files = e.dataTransfer.files;
                handleFileSelect();
            }
        });
    }
    
    // Remove image preview
    if (removeButton) {
        removeButton.addEventListener('click', function(e) {
            e.stopPropagation();
            resetFileInput();
        });
    }
    
    // Model selection
    if (modelBadges) {
        modelBadges.forEach(badge => {
            badge.addEventListener('click', function() {
                // Remove active class from all badges
                modelBadges.forEach(b => b.classList.remove('active'));
                
                // Add active class to clicked badge
                this.classList.add('active');
                
                // Here you could also update a hidden input with the selected model
                // const selectedModel = this.getAttribute('data-model');
                // document.getElementById('model-input').value = selectedModel;
            });
        });
    }
    
    function handleFileSelect() {
        if (fileInput.files && fileInput.files[0]) {
            const file = fileInput.files[0];
            
            if (!file.type.match('image.*')) {
                alert('Please select an image file.');
                resetFileInput();
                return;
            }
            
            const reader = new FileReader();
            
            reader.onload = function(e) {
                uploadText.classList.add('d-none');
                previewContainer.classList.remove('d-none');
                imagePreview.src = e.target.result;
                classifyBtn.disabled = false;
            };
            
            reader.readAsDataURL(file);
        }
    }
    
    function resetFileInput() {
        fileInput.value = '';
        previewContainer.classList.add('d-none');
        uploadText.classList.remove('d-none');
        classifyBtn.disabled = true;
    }
});
